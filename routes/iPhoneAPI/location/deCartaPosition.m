//
//  deCartaPosition.m
//  deCartaLibrary
//
//  Created by Scott Gruby on 10/3/08.
//  Copyright 2008-09 deCarta, Inc. All rights reserved.
//

#import "deCartaPosition.h"


@implementation deCartaPosition
@synthesize lat=_lat;
@synthesize lon=_lon;

- (id) initWithLat:(double) inLat andLon:(double) inLon
{
	self=[super init];
    if(self){
		if(inLat==90) _lat=90;
		else {
			_lat=((int)inLat+90+180)%180-90+(inLat-(int)inLat);
		}
		
		_lon=((int)inLon+180+360)%360-180+(inLon-(int)inLon);
	}
		
	return self;
}

- (id) initWithString:(NSString *) latlon
{
	if ([latlon length]<=0)
	{
		return nil;
	}
    
    NSScanner *scanner = [NSScanner scannerWithString:latlon];
    double lat;
    double lon;
    [scanner scanDouble:&lat];
    [scanner scanDouble:&lon];

	return [self initWithLat:lat andLon:lon];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"%f %f", _lat, _lon];
}

- (id)copyWithZone:(NSZone *)zone
{
    deCartaPosition *copy = [[deCartaPosition alloc] 
							 initWithLat:_lat andLon:_lon];
    
    return copy;
}

-(unsigned int)hash{
	unsigned int h = 7;
	int * intLat=(int *)&_lat;
	int * intLon=(int *)&_lon;
	h = 97 * h + intLat[0] ^ intLat[1];
	h = 97 * h + intLon[0] ^ intLon[1];
	return h;
}

- (BOOL) isEqual:(id) inObject
{
	if (inObject == nil)
	{
		return NO;
	}
	
	if (![inObject isKindOfClass:[self class]])
	{
		return NO;
	}
	
	deCartaPosition * obj=inObject;
	
	if (obj.lat == _lat && obj.lon == _lon)
	{
		return YES;
	}
	
	return NO;
}

+(deCartaPosition *) positionWithLat:(double)inLat andLon:(double)inLon{
	return [[[deCartaPosition alloc] initWithLat:inLat andLon:inLon] autorelease];
}
+(deCartaPosition *) positionWithString:(NSString *)latlon{
	return [[[deCartaPosition alloc] initWithString:latlon] autorelease];
}

@end
