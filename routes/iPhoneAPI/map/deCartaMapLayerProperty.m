//
//  deCartaMapLayerProperty.m
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaMapLayerProperty.h"

static NSMutableDictionary * MapLayerType_MapLayerProperty=nil;

@implementation deCartaMapLayerProperty
@synthesize mapLayerType;
@synthesize tileImageSizeFactor;
@synthesize templateSeedTileUrl;
@synthesize configuration;
@synthesize sessionId;
@synthesize format;

-(id)initWithMapLayerType:(MapLayerType)inMapLayerType{
	self=[super init];
    if(self){
		mapLayerType=inMapLayerType;
		tileImageSizeFactor=1;
		templateSeedTileUrl=@"";
		configuration=@"";
		sessionId=@"";
	}
	return self;
}

-(void)dealloc{
	[templateSeedTileUrl release];
	[configuration release];
	[sessionId release];
	[super dealloc];
}

+(deCartaMapLayerProperty *)getInstance:(MapLayerType)inMapLayerType{
	if(MapLayerType_MapLayerProperty==nil){
		MapLayerType_MapLayerProperty=[[NSMutableDictionary alloc] initWithCapacity:NUM_OF_MAPLAYER_TYPE];
		for(int i=0;i<NUM_OF_MAPLAYER_TYPE;i++){
			NSNumber * n=[NSNumber numberWithInt:i];
			deCartaMapLayerProperty * p=[[deCartaMapLayerProperty alloc] initWithMapLayerType:[n intValue]];
			[MapLayerType_MapLayerProperty setObject:p forKey:n];
			[p release];
		}
	}
	return (deCartaMapLayerProperty *)[MapLayerType_MapLayerProperty objectForKey:[NSNumber numberWithInt:inMapLayerType]];
}
	
@end
