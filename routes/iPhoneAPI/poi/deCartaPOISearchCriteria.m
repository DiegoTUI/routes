//
//  deCartaPOISearchCriteria.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaPOISearchCriteria.h"


@implementation deCartaPOISearchCriteria
@synthesize centerPosition=_centerPosition;
@synthesize radius=_radius;
@synthesize queryString=_queryString;
@synthesize maximumResponses=_maximumResponses;
@synthesize database=_database;
@synthesize rankCriteria=_rankCriteria;
@synthesize sortCriteria=_sortCriteria;
@synthesize sortDirection=_sortDirection;
@synthesize queryType=_queryType;
@synthesize allowAggregates=_allowAggregates;

@synthesize routeId=_routeId;
@synthesize duration=_duration;
@synthesize corridorType=_corridorType;
@synthesize distance=_distance;
@synthesize queryTypeAdj=_queryTypeAdj;
@synthesize queryStringAdj=_queryStringAdj;

-(id)init{
	self=[super init];
    if(self){
		_centerPosition=nil;
		_radius=5000;
		_queryString=nil;
		_maximumResponses=10;
		_database=@"search:deCarta:poi";
		_rankCriteria=nil;
		_sortCriteria=nil;
		_sortDirection=@"Ascending";
		_queryType=@"POIName";
		_allowAggregates=FALSE;
		
		_routeId=nil;
		_duration=0;
		_corridorType=@"distance";
		_distance=1000;
		
		_queryTypeAdj=@"CATEGPORY";
		_queryStringAdj=nil;
	}
	return self;
}


-(void)dealloc{
	[_centerPosition release];
	[_queryString release];
	[_database release];
	[_rankCriteria release];
	[_sortCriteria release];
	[_sortDirection release];
	[_queryType release];
	[_routeId release];
	[_corridorType release];
	[_queryTypeAdj release];
	[_queryStringAdj release];
	
	[super dealloc];
}
	
@end
