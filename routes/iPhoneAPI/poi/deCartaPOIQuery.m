//
//  deCartaPOIQuery.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaPOIQuery.h"
#import "deCartaXMLProcessor.h"
#import "deCartaWebServices.h"

@implementation deCartaPOIQuery
+(NSArray *)query:(deCartaPOISearchCriteria *)criteria{
	NSData * xml=[deCartaXMLProcessor poiRequest:criteria];
	NSData * data=[deCartaWebServices postViaHttpConnection:xml];
	return [deCartaXMLProcessor processPOI:data];
}
@end
