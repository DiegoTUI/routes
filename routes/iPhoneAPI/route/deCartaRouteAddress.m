//
//  deCartaRouteAddress.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaRouteAddress.h"

@implementation deCartaRouteAddress
@synthesize name=_name;
@synthesize position=_position;

-(id)init{
	self=[super init];
    if(self){
	}
	return self;
}

-(id)initWithName:(NSString *)name position:(deCartaPosition *)position
{
	self=[super init];
    if(self){
		self.name=name;
		self.position=position;
	}
	
	return self;
	
}

-(void)dealloc{
	[_name release];
	[_position release];
	[super dealloc];
}
@end
