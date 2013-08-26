//
//  deCartaPOI.m
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaPOI.h"


@implementation deCartaPOI
@synthesize name=_name;
@synthesize phoneNumber=_phoneNumber;
@synthesize address=_address;
@synthesize position=_position;
@synthesize distance=_distance;
@synthesize distanceOnRoute=_distanceOnRoute;
@synthesize distanceOffRoute=_distanceOffRoute;
@synthesize durationOnRoute=_durationOnRoute;
@synthesize durationOffRoute=_durationOffRoute;

- (BOOL)isEqual:(id)object
{
    if(object==nil) return false;
    
    deCartaPOI *poi=object;
    if([_name isEqual:poi.name] && [_phoneNumber isEqual:poi.phoneNumber] && [_position isEqual:poi.position]){
        return true;
    }
    
    return false;
}

- (unsigned int)hash
{
    unsigned int hash=3;
    hash=29*hash + ([_name length]>0?[_name hash]:0);
    hash=29*hash + ([_phoneNumber length]>0?[_phoneNumber hash]:0);
    hash=29*hash + (_position?[_position hash]:0);
    
    return hash;
}

- (void)dealloc{
    [_name release];
    [_phoneNumber release];
    [_address release];
    [_position release];
    [_distance release];
    [_distanceOnRoute release];
    [_distanceOffRoute release];
    
    [super dealloc];
}
@end
