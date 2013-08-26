//
//  deCartaGeocodeResponse.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaGeocodeResponse.h"


@implementation deCartaGeocodeResponse
@synthesize accuracy=_accuracy;
@synthesize matchType=_matchType;
@synthesize address=_address;
@synthesize position=_position;

-(NSString *)description{
	return [NSString stringWithFormat:@"%@ %@\n%@\n%@: %f",_address,_address.locale.countryCode,_position,_matchType,_accuracy];
}
-(void)dealloc{
	[_matchType release];
	[_address release];
	[_position release];
	[super dealloc];
}
@end
