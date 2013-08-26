//
//  deCartaPolygon.m
//  iPhoneRefApp
//
//  Created by Z.S. on 3/21/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaPolygon.h"
#import "deCartaGlobals.h"
#import "deCartaUtil.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@implementation deCartaPolygon
@synthesize positions=_positions;

-(id)initWithPositions:(NSArray *)positions name:(NSString *)name{
	self=[super initWithName:name];
    if(self){
		_fillColor=0xff0000ff;
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
	
	[super dealloc];
}

#pragma mark -
#pragma mark @implementation methods used only in API

-(void)renderGL:(deCartaXYDouble *)topLeftXY atZoom:(float)zoomLevel{
	if([_mercXYs count] <3) return;
	
	double zoomScale=pow(2,zoomLevel-ZOOM_LEVEL);
	float red=((_fillColor & 0x00ff0000)>>16)/(float)255;
	float green=((_fillColor & 0x0000ff00)>>8)/(float)255;
	float blue=((_fillColor & 0x000000ff))/(float)255;
	glDisable(GL_TEXTURE_2D);
	glColor4f(red,green,blue,_opacity);
	
	float * verts=calloc([_mercXYs count]*2, sizeof(float));
	for(int i=0;i<[_mercXYs count];i++){
		deCartaXYDouble * merc=[_mercXYs objectAtIndex:i];
		float x=(float)(merc.x*zoomScale-topLeftXY.x);
		float y=(float)(-merc.y*zoomScale+topLeftXY.y);
		verts[2*i]=x;
		verts[2*i+1]=y;
		
	}
	
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glDrawArrays(GL_TRIANGLE_FAN, 0, [_mercXYs count]);
	
	free(verts);
}
@end
