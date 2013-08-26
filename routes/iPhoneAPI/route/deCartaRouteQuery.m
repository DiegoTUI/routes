//
//  deCartaRouteQuery.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaRouteQuery.h"
#import "deCartaXMLProcessor.h"
#import "deCartaWebServices.h"

@implementation deCartaRouteQuery
+(deCartaRoute *)query:(NSArray *)positions routePreference:(deCartaRoutePreference *)routePreference{
	NSData * xml=[deCartaXMLProcessor routeRequest:positions prefs:routePreference];
	NSData * data=[deCartaWebServices postViaHttpConnection:xml];
	return [deCartaXMLProcessor processRoute:data];
}

@end
