//
//  TileGridResponse.m
//  iPhoneApp
//
//  Created by Z.S. on 2/4/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaTileGridResponse.h"


@implementation deCartaTileGridResponse
@synthesize radiusY;
@synthesize centerPosition;
@synthesize tileGridCenterPosition;
@synthesize fixedGridPixelOffset;
@synthesize seedTileUrl;

@synthesize centerXYZ;
@synthesize centerXY;

-(void)dealloc{
	[radiusY release];
	[centerPosition release];
	[tileGridCenterPosition release];
	[fixedGridPixelOffset release];
	[seedTileUrl release];
	[centerXYZ release];
	[centerXY release];
	[super dealloc];
}

@end
