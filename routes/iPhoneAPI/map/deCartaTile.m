//
//  Tile.m
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaTile.h"


@implementation deCartaTile
@synthesize xyz;
@synthesize distanceFromCenter;
@synthesize mapLayerProperty;

-(id)initWithMapLayerProperty:(deCartaMapLayerProperty *)inMapLayerProperty{
	self=[super init];
    if(self){
		mapLayerProperty=[inMapLayerProperty retain];
		xyz=[[deCartaXYZ alloc] initWithX:0 andY:0 andZ:0];
	}
	return self;
}

-(BOOL)isEqual:(id)inObj{
	if(inObj == nil) return NO;
	if([inObj isKindOfClass:[deCartaTile class]]){
		deCartaTile * t=(deCartaTile *)inObj;
		return [xyz isEqual:t.xyz] && mapLayerProperty==t.mapLayerProperty;
	}
	return NO;	
}

-(NSUInteger)hash{
	unsigned int hash=29 * [xyz hash] + (int)mapLayerProperty;
	return hash;
}

-(id) copyWithZone:(NSZone *)zone
{
	deCartaTile * tile=[[deCartaTile allocWithZone:zone] initWithMapLayerProperty:mapLayerProperty];
	tile.xyz.x=xyz.x;
	tile.xyz.y=xyz.y;
	tile.xyz.z=xyz.z;
	return tile;
	
}

-(NSString *)description{
	return [NSString stringWithFormat:@"%@_%d_%@",[xyz description],mapLayerProperty.mapLayerType,mapLayerProperty.configuration];
}

-(void)dealloc{
	[mapLayerProperty release];
	[xyz release];
	[super dealloc];
}

@end
