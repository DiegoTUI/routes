//
//  MapLayer.m
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaMapLayer.h"
#import "deCartaTile.h"

@implementation deCartaMapLayer

@synthesize mapLayerProperty;
@synthesize mainLayerDrawPercent;
@synthesize visible;
@synthesize centerXYZ;
@synthesize centerDelta;
@synthesize centerXY;
@synthesize zoomLayerDrawPercent;

-(id)initWithMapLayerProperty:(deCartaMapLayerProperty *)inMapLayerProperty{
	self=[super init];
    if(self){
		self.mapLayerProperty=inMapLayerProperty;
		centerXY=nil;
		mainLayerDrawPercent=0;
		visible=FALSE;
		zoomLayerDrawPercent=0;
		centerXYZ=[[deCartaXYZ alloc] initWithX:0 andY:0 andZ:-1];
		centerDelta=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	}
	return self;
}

-(deCartaTile *) createTile{
	return [[[deCartaTile alloc] initWithMapLayerProperty:self.mapLayerProperty] autorelease];
}
	
-(void)dealloc{
	[mapLayerProperty release];
	[centerXYZ release];
	[centerXY release];
	[centerDelta release];
	[super dealloc];
}
			
@end
