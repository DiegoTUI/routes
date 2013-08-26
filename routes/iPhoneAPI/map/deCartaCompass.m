//
//  Compass.m
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "deCartaCompass.h"
#import "deCartaGlobals.h"

static deCartaXYInteger * DEF_OFFSET=nil;
static deCartaXYInteger * DEF_SIZE=nil;
static deCartaCompassLocationEnum DEF_COMPASS_LOCATION=COMPASS_TOP_LEFT;

@interface deCartaCompass (Private)
-(void)set_vertexS;

@end
@implementation deCartaCompass (Private)

-(void)set_vertexS{
	_vertexN[0]=-_size.x/2.0f;
	_vertexN[1]=0;
	_vertexN[2]=_size.x/2;
	_vertexN[3]=0;
	_vertexN[4]=0;
	_vertexN[5]=-_size.y/2;
	
	_vertexS[0]=-_size.x/2.0f;
	_vertexS[1]=0;
	_vertexS[4]=0;
	_vertexS[5]=_size.y/2;
	_vertexS[2]=_size.x/2;
	_vertexS[3]=0;
	
}

@end

@implementation deCartaCompass
@synthesize colorS=_colorS,colorN=_colorN;
@synthesize size=_size,offset=_offset;
@synthesize compassLocation=_compassLocation;
@synthesize visible=_visible;

+(void)initialize{
	DEF_OFFSET=[[deCartaXYInteger alloc] initWithXi:25 andYi:25];
	DEF_SIZE=[[deCartaXYInteger alloc] initWithXi:10 andYi:40];
}

-(id)init{
	return [self initWithSize:DEF_SIZE offset:DEF_OFFSET compassLocation:DEF_COMPASS_LOCATION];
}
			
-(id)initWithSize:(deCartaXYInteger *)size offset:(deCartaXYInteger *)offset compassLocation:(deCartaCompassLocationEnum)compassLocation{
	
	self=[super init];
    if(self){
		_colorN=0xffff0000;
		_colorS=0xff0000ff;
		
		_size=[[deCartaXYInteger alloc] init];
		_offset=[[deCartaXYInteger alloc] init];
		_compassLocation=DEF_COMPASS_LOCATION;
		_visible=TRUE;
		
		_eventListeners=[[NSMutableDictionary alloc] init];
		
		_size.x=size.x;
		_size.y=size.y;
		_offset.x=offset.x;
		_offset.y=offset.y;
		_compassLocation=compassLocation;
		
		[self set_vertexS];

	}
	
	return self;

}


-(BOOL)addEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	if([_eventListeners objectForKey:[NSNumber numberWithInt:eventType]]==nil){
		[_eventListeners setObject:[NSMutableArray array] forKey:[NSNumber numberWithInt:eventType]];
	}
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	if(![array containsObject:listener]) [array addObject:listener];
	
	return TRUE;
}
-(void)removeEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array removeObject:listener];
}
-(void)removeEventListeners:(int)eventType{
	[_eventListeners removeObjectForKey:[NSNumber numberWithInt:eventType]];
	
}

-(void)executeEventListeners:(int)eventType withParam:(id)param{
	
	NSArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	for(deCartaEventListener * listener in array){
		(listener.callback)(self,param);
	}
}

-(void)dealloc{
	[_size release];
	[_offset release];
	[_eventListeners release];
	[super dealloc];
}

#pragma mark -
#pragma mark @implementation methods used only in API

-(void)renderGL{
	glScalef(g_scale, g_scale, 1);
	glVertexPointer(2, GL_FLOAT, 0, _vertexN);
	
	glColor4f(((_colorN & 0x00ff0000)>>16)/(float)255, ((_colorN & 0x0000ff00)>>8)/(float)255, ((_colorN & 0x000000ff))/(float)255, 1);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 3);
	
	glVertexPointer(2, GL_FLOAT, 0, _vertexS);
	
	glColor4f(((_colorS & 0x00ff0000)>>16)/(float)255, ((_colorS & 0x0000ff00)>>8)/(float)255, ((_colorS & 0x000000ff))/(float)255, 1);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 3);
}

-(BOOL)snapTo:(deCartaXYFloat *)screenXY displaySize:(deCartaXYInteger *)displaySize{
	float bufferW=10*g_scale;
	float bufferH=10*g_scale;
	
	deCartaXYInteger * xy=[self getScreenXY:displaySize];
	
	if(xy.x-_size.x/2*g_scale-bufferW<screenXY.x && xy.x+_size.x/2*g_scale+bufferW>screenXY.x 
	   && xy.y-_size.y/2*g_scale-bufferH<screenXY.y && xy.y+_size.y/2*g_scale+bufferH>screenXY.y){
		return true;
	}
	return false;
}

-(deCartaXYInteger *)getScreenXY:(deCartaXYInteger *)displaySize{
	int x=_offset.x*g_scale;
	int y=_offset.y*g_scale;
	if(_compassLocation==COMPASS_TOP_RIGHT){
		
		x=displaySize.x-_offset.x*g_scale;
	}else if(_compassLocation==COMPASS_BOTTOM_LEFT){
		y=displaySize.y-_offset.y*g_scale;
	}else if(_compassLocation==COMPASS_BOTTOM_RIGHT){
		x=displaySize.x-_offset.x*g_scale;
		y=displaySize.y-_offset.y*g_scale;
	}
	return [[[deCartaXYInteger alloc] initWithXi:x andYi:y] autorelease];
}

@end
