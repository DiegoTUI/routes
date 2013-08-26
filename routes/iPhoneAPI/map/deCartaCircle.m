//
//  deCartaCircle.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaCircle.h"
#import "deCartaGlobals.h"
#import "deCartaUtil.h"
#import "deCartaConfig.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_CIRCLE_VERTS 52

static float CircleVertexBuffer[MAX_CIRCLE_VERTS*2];

@implementation deCartaCircle


@synthesize radius=_radius;
@synthesize position=_position;
@synthesize mercXY=_mercXY;

+(void)initialize{
	
	float radient=(float)(M_PI*2/(MAX_CIRCLE_VERTS-2));
	int idx=0;
	CircleVertexBuffer[idx++]=0;
	CircleVertexBuffer[idx++]=0;
	for(int i=0;i<MAX_CIRCLE_VERTS-2;i++){
		CircleVertexBuffer[idx++]=cosf(i*radient);
		CircleVertexBuffer[idx++]=-sinf(i*radient);
	}
	CircleVertexBuffer[idx++]=1;
	CircleVertexBuffer[idx++]=0;
}

-(id)initWithPosition:(deCartaPosition *)inPosition radius:(deCartaLength *)inRadius name:(NSString *)inName{
	self = [super initWithName:inName];
    if(self){
		_fillColor=0xff0000ff;
		_opacity=0.2f;
		_radius=[[deCartaLength alloc] initWithDistance:0 andUOM:M];
		
		[self setPosition:inPosition];
		[self setRadius:inRadius];
	}
	
	return self;
}

-(void)setPosition:(deCartaPosition *)inPosition{
	@try {
		[_mercXY release];
		_mercXY=[[deCartaUtil posToMercPix:inPosition atZoom:ZOOM_LEVEL] retain];
		[_position release];
		_position=[inPosition retain];
		
	}
	@catch (NSException * e) {
		[_mercXY release];
		_mercXY=nil;
		[_position release];
		_position=nil;
		@throw e;
	}
	
}

-(void)dealloc{
	[_radius release];
	[_position release];
	[_mercXY release];
	[super dealloc];
}

#pragma mark -
#pragma mark @implementation methods used only in API
-(void)renderGL:(deCartaXYDouble *)topLeftXY atZoom:(float)zoomLevel{
	double shapeZoomScale=pow(2,zoomLevel-ZOOM_LEVEL);
	float x=(float)(_mercXY.x*shapeZoomScale-topLeftXY.x);
	float y=(float)(-_mercXY.y*shapeZoomScale+topLeftXY.y);
	
	float radiusN=(float)([_radius toMeters]/[deCartaUtil metersPerPixel:g_config.TILE_SIZE atZoom:zoomLevel atLat:_position.lat]);
	float red=((_fillColor & 0x00ff0000)>>16)/(float)255;
	float green=((_fillColor & 0x0000ff00)>>8)/(float)255;
	float blue=((_fillColor & 0x000000ff))/(float)255;
	glDisable(GL_TEXTURE_2D);
	glColor4f(red,green,blue,_opacity);
	
	glPushMatrix();
	glTranslatef(x,y,0);
	glScalef(radiusN, radiusN, 1);
	glVertexPointer(2, GL_FLOAT, 0, CircleVertexBuffer);
	glDrawArrays(GL_TRIANGLE_FAN, 0, MAX_CIRCLE_VERTS);
	glPopMatrix();
}

@end
