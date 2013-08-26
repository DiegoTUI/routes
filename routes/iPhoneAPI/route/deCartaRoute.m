//
//  deCartaRoute.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaRoute.h"


@implementation deCartaRoute
@synthesize boundingBox=_boundingBox;
@synthesize totalTime=_totalTime;
@synthesize totalDistance=_totalDistance;
@synthesize viaPointSequence=_viaPointSequence;
@synthesize routeInstructions=_routeInstructions;
@synthesize routeGeometry=_routeGeometry;
@synthesize routeId=_routeId;

-(id)init{
	self=[super init];
    if(self){
		_boundingBox=[[deCartaBoundingBox alloc] init];
		_routeInstructions=[[NSMutableArray alloc] init];
		_routeGeometry=[[NSMutableArray alloc] init];
	}
	
	return self;
}


-(NSString *)getSummary{
	return [NSString stringWithFormat:@"%@ - about %@",_totalDistance,_totalTime];
	
}

-(void)dealloc{
	[_boundingBox release];
	[_totalTime release];
	[_totalDistance release];
	[_viaPointSequence release];
	[_routeInstructions release];
	[_routeGeometry release];
	[_routeId release];
	[super dealloc];
}

@end
