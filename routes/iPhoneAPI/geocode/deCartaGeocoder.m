//
//  Geocoder.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaGeocoder.h"
#import "deCartaWebServices.h"
#import "deCartaXMLProcessor.h"

@implementation deCartaGeocoder
+(deCartaStructuredAddress *)reverseGeocode:(deCartaPosition *)position{
	NSData * xml=[deCartaXMLProcessor reverseGeocodeRequest:position];
	NSData * data=[deCartaWebServices postViaHttpConnection:xml];
	if([data length]>0){
		return [deCartaXMLProcessor processReverseGeocode:data];
	}
	return nil;
}
+(NSArray *)geocode:(deCartaAddress *)address returnFreeFormAddress:(BOOL)returnFreeFormAddrss{
	
	
	NSData * xml=[deCartaXMLProcessor geocodeRequest:address returnFreeFormAddress:returnFreeFormAddrss];
	NSData *data = [deCartaWebServices postViaHttpConnection:xml];
	if ([data length]>0)
	{
		return [deCartaXMLProcessor processGeocode:data returnFreeFormAddress:returnFreeFormAddrss];
	}
		
	return nil;
}
@end
