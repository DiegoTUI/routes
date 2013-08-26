//
//  deCartaPolyline.m
//  iPhoneApp
//
//  Created by Z.S. on 3/10/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "deCartaPolyline.h"
#import "deCartaGlobals.h"
#import "deCartaConfig.h"
#import "deCartaUtil.h"
#import "deCartaLogger.h"


static float GRANULARITY=10/1.5f;
static int GENERALIZE_ZOOM_LEVEL[21][2]={
	{4,2},  //zoom 0
	{4,2},  //zoom 1
	{4,2},  //zoom 2
	{4,2},  //zoom 3
	{4,2},  //zoom 4
	{7,6},  //zoom 5
	{7,6},  //zoom 6
	{7,6},  //zoom 7, max 80 points
	{9,9},  //zoom 8, max 220 points
	{9,9},  //zoom 9, max 100 points
	{11,11}, //zoom 10, max 220 points
	{11,11}, //zoom 11, max 100 points
	{13,13}, //zoom 12, max 170 points
	{13,13}, //zoom 13, max 90 points
	{20,15}, //zoom 14, max 150 points
	{20,15}, //zoom 15
	{20,15}, //zoom 16
	{20,15}, //zoom 17
	{20,15}, //zoom 18
	{20,15}, //zoom 19
	{20,15}  //zoom 20
};
static float vertexBuffer[2*2];

@interface deCartaPolyline (Private)
-(void)generalizePoints:(int)zoomLevel;
-(NSArray *)getPointIdxs:(int)zoomLevel tiles:(NSArray *)tiles;
@end

@implementation deCartaPolyline (Private)
-(void)generalizePoints:(int)zoomLevel{
	int genLevel=GENERALIZE_ZOOM_LEVEL[zoomLevel][0];
	int idxLevel=GENERALIZE_ZOOM_LEVEL[zoomLevel][1];
	double scale=pow(2, idxLevel-ZOOM_LEVEL);
	
	if(genLevel==20){
		if(_pointIdxs[idxLevel]==nil){
			NSMutableDictionary * pointIdx=[[NSMutableDictionary alloc] init];
			
			for(int i=0;i<[_positions count];i++){
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:i];
				deCartaXYDouble * mercXY=[[[deCartaXYDouble alloc] initWithXd:merc.x*scale andYd:merc.y*scale] autorelease];
				deCartaXYInteger * ne = [deCartaUtil mercXYToNE:mercXY];
				deCartaXYZ * key=[[[deCartaXYZ alloc] initWithX:ne.x andY:ne.y andZ:idxLevel] autorelease];
				if([pointIdx objectForKey:key]==nil) [pointIdx setObject:[NSMutableArray array] forKey:key];
				[(NSMutableArray *)[pointIdx objectForKey:key] addObject:[NSNumber numberWithInt:i]];
				
			}
			_pointIdxs[idxLevel]=pointIdx;
		}
	}else{
		if (_generalizedPosIdxs[genLevel]==nil){
			double zoomScale=pow(2, ZOOM_LEVEL-genLevel);
			double minDist=(GRANULARITY*g_scale*GRANULARITY*g_scale)*(zoomScale*zoomScale);
			
			NSMutableArray * genIdx=[[NSMutableArray alloc] init];
			double lastX=0;
			double lastY=0;
			for (int i = 0; i < [_positions count]; i++){
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:i];
				double dist=(merc.x-lastX)*(merc.x-lastX)+(merc.y-lastY)*(merc.y-lastY);
				if(i==0 || dist>minDist || i==[_positions count]-1){
					[genIdx addObject:[NSNumber numberWithInt:i]];
					lastX=merc.x;
					lastY=merc.y;
				}
			}
			_generalizedPosIdxs[genLevel]=genIdx;
		}
		
		if(_pointIdxs[idxLevel]==nil){
			NSMutableDictionary * pointIdx=[[NSMutableDictionary alloc] init];
			
			for(int i=0;i<[_generalizedPosIdxs[genLevel] count];i++){
				int idx=[(NSNumber *)[_generalizedPosIdxs[genLevel] objectAtIndex:i] intValue];
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:idx];
				deCartaXYDouble * mercXY=[[[deCartaXYDouble alloc] initWithXd:merc.x*scale andYd:merc.y*scale] autorelease];
				deCartaXYInteger * ne = [deCartaUtil mercXYToNE:mercXY];
				deCartaXYZ * key=[[[deCartaXYZ alloc] initWithX:ne.x andY:ne.y andZ:idxLevel] autorelease];
				if([pointIdx objectForKey:key]==nil) [pointIdx setObject:[NSMutableArray array] forKey:key];
				[(NSMutableArray *)[pointIdx objectForKey:key] addObject:[NSNumber numberWithInt:i]];
				
			}
			_pointIdxs[idxLevel]=pointIdx;
		}
	}
}

-(NSArray *)getPointIdxs:(int)zoomLevel tiles:(NSArray *)tiles{
	[self generalizePoints:zoomLevel];
	int idxLevel=GENERALIZE_ZOOM_LEVEL[zoomLevel][1];
	NSMutableArray * idx=[NSMutableArray array];
	NSDictionary * pointIdx=_pointIdxs[idxLevel];
	
	/*NSMutableArray * overlapTiles=[NSMutableArray array];
	 for(int i=0;i<[tiles count];i++){
	 deCartaTile * tile=[tiles objectAtIndex:i];
	 NSArray * xyzs=[deCartaUtil findOverlapTiles:tile.xyz atZ:idxLevel];
	 if(![overlapTiles containsObject:[xyzs objectAtIndex:0]]){
	 [overlapTiles addObjectsFromArray:xyzs];
	 }
	 
	 }*/
	NSArray * overlapTiles=[deCartaUtil findOverlapXYZs:tiles atZ:idxLevel];
	
	for(int j=0;j<[overlapTiles count];j++){
		deCartaXYZ * xyz=[overlapTiles objectAtIndex:j];
		deCartaXYZ * key=xyz;
		if([pointIdx objectForKey:key]){
			[idx addObjectsFromArray:[pointIdx objectForKey:key]];
		}
	}
	
	
	[idx sortUsingSelector:@selector(compare:)];
	
	return idx;
	
}
@end

@implementation deCartaPolyline
@synthesize positions=_positions;
@synthesize mercXYs=_mercXYs;
@synthesize strokeSize=_strokeSize;

-(id)initWithPositions:(NSArray *)positions name:(NSString *)name{
	self= [super initWithName:name];
    if(self){
		_fillColor=0xff0000ff;
		_strokeSize=8;
		_opacity=0.6f;
		_mercXYs=[[NSMutableArray alloc] init];
		
		[self setPositions:positions];
	}		
	
	return self;
}

-(void)setPositions:(NSArray *)inPositions{
	if(_positions == inPositions) return;
	[_positions release];
	_positions=nil;
	[_mercXYs removeAllObjects];
	if(inPositions!=nil){
		_positions=[inPositions retain];
		@try {
			for(int m=0;m<[inPositions count];m++){
				[_mercXYs addObject:[deCartaUtil posToMercPix:[inPositions objectAtIndex:m] atZoom:ZOOM_LEVEL]];
			}
		}
		@catch (NSException * e) {
			[_positions release];
			_positions=nil;
			[_mercXYs removeAllObjects];
			@throw e;
		}
	}
}


-(void)dealloc{
	[_positions release];
	[_mercXYs release];
	for(int i=0;i<21;i++){
		[_generalizedPosIdxs[i] release];
		[_pointIdxs[i] release];
	}
	[super dealloc];
}

#pragma mark -
#pragma mark @implementation methods used only in API
void drawLine(float x1, float y1, float x2, float y2){
	
	vertexBuffer[0]=x1;
	vertexBuffer[1]=y1;
	vertexBuffer[2]=x2;
	vertexBuffer[3]=y2;
	glDrawArrays(GL_LINE_STRIP, 0, 2);
	//glDrawArrays(GL_POINTS, 0, 2);
}

-(void)renderGL:(deCartaXYDouble *)topLeftXY zoomLevel:(float)zoomLevel z:(int)z tiles:(NSArray *)drawTiles{
	NSArray * pointIdx=[self getPointIdxs:z tiles:drawTiles];
	if([pointIdx count]==0) return;
	
	float lastX=0;
	float lastY=0;
	BOOL broken=FALSE;
	
	int genLevel=GENERALIZE_ZOOM_LEVEL[z][0];
	
	//glDepthMask(FALSE);
	glDisable(GL_TEXTURE_2D);
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	float red=((_fillColor & 0x00ff0000)>>16)/(float)255;
	float green=((_fillColor & 0x0000ff00)>>8)/(float)255;
	float blue=((_fillColor & 0x000000ff))/(float)255;
	glColor4f(red, green, blue, _opacity);
	int widths[2];
	glGetIntegerv(GL_ALIASED_LINE_WIDTH_RANGE, widths);
	int width=_strokeSize;
	if(widths[1]>0 && width>widths[1]){
		width=widths[1];
	}
	glLineWidth(width);
	glPointSize(width/2.0f);
	
	double zoomScale=powf(2,zoomLevel-ZOOM_LEVEL);
	//[deCartaLogger debug:[NSString stringWithFormat:@"Polyline renderGL pointIdx count:%d",[pointIdx count]]];
	for(int m=0;m<[pointIdx count];m++){
		double xx=0,yy=0;
		if(genLevel==20){
			deCartaXYDouble * merc=[_mercXYs objectAtIndex:[[pointIdx objectAtIndex:m] intValue]];
			xx=merc.x;
			yy=merc.y;
			
		}else{
			int idx=[[_generalizedPosIdxs[genLevel] objectAtIndex:[[pointIdx objectAtIndex:m] intValue]] intValue];
			deCartaXYDouble * merc=[_mercXYs objectAtIndex:idx];
			xx=merc.x;
			yy=merc.y;
		}
		float x=(float)(xx*zoomScale-topLeftXY.x);
		float y=(float)(-yy*zoomScale+topLeftXY.y);
		
		if((m==0 && [[pointIdx objectAtIndex:m] intValue]!=0) || (m!=0 && broken)){
			double preXX=0,preYY=0;
			if(genLevel==20){
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:[[pointIdx objectAtIndex:m] intValue]-1];
				preXX=merc.x;
				preYY=merc.y;
			}else{
				int idx=[[_generalizedPosIdxs[genLevel] objectAtIndex:[[pointIdx objectAtIndex:m] intValue]-1] intValue];
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:idx];
				preXX=merc.x;
				preYY=merc.y;
			}
			float preX=(float)(preXX*zoomScale-topLeftXY.x);
			float preY=(float)(-preYY*zoomScale+topLeftXY.y);
			drawLine(preX, preY, x, y);
			
		}else if(m!=0){
			drawLine(lastX, lastY, x, y);
			
		}
		
		broken=FALSE;
		int genSize=(genLevel==20)?[_positions count]:[_generalizedPosIdxs[genLevel] count];
		if((m!=[pointIdx count]-1 && [[pointIdx objectAtIndex:m] intValue]+1!=[[pointIdx objectAtIndex:m+1] intValue])
		   || (m==[pointIdx count]-1 && [[pointIdx objectAtIndex:m] intValue]!=genSize-1)){
			double nextXX=0, nextYY=0;
			if(genLevel==20){
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:[[pointIdx objectAtIndex:m] intValue]+1];
				nextXX=merc.x;
				nextYY=merc.y;
				
			}else{
				int idx=[[_generalizedPosIdxs[genLevel] objectAtIndex:[[pointIdx objectAtIndex:m] intValue]+1] intValue];
				deCartaXYDouble * merc=[_mercXYs objectAtIndex:idx];
				nextXX=merc.x;
				nextYY=merc.y;
				
			}
			float nextX=(float)(nextXX*zoomScale-topLeftXY.x);
			float nextY=(float)(-nextYY*zoomScale+topLeftXY.y);
			drawLine(x, y, nextX, nextY);
			
			broken=true;
		}
		
		lastX=x;
		lastY=y;
		
	}
	
	glEnable(GL_TEXTURE_2D);
	glColor4f(1, 1, 1, 1);
	glLineWidth(1);
	glPointSize(1);
	//glDepthMask(TRUE);
}

@end
