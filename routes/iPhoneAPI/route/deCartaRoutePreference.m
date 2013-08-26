//
//  deCartaRoutePreference.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaRoutePreference.h"


@implementation deCartaRoutePreference
@synthesize clippingBox=_clippingBox;
@synthesize returnInstructions=_returnInstructions;
@synthesize returnGeometry=_returnGeometry;
@synthesize returnRouteIdOnly=_returnRouteIdOnly;
@synthesize style=_style;
@synthesize routeQueryType=_routeQueryType;
@synthesize rules=_rules;
@synthesize optimized=_optimized;
@synthesize expectedStartTime=_expectedStartTime;
@synthesize provideRouteHandle=_provideRouteHandle;
@synthesize distanceType=_distanceType;

-(id)init{
	self=[super init];
    if(self){
		_returnInstructions=TRUE;
		_returnGeometry=TRUE;
		_returnRouteIdOnly=FALSE;
		self.style=@"Fastest";
		self.routeQueryType=@"RTXT";
		_optimized=FALSE;
		_provideRouteHandle=TRUE;
		self.distanceType=@"MI";
	}
	return self;
}


-(void)dealloc{
	[_clippingBox release];
	[_style release];
	[_routeQueryType release];
	[_distanceType release];
	[super dealloc];
}

@end
