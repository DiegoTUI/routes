//
//  deCartaXY.m
//  deCartaLibrary
//
//  Created by Scott Gruby on 10/3/08.
//  Copyright 2008-09 deCarta, Inc. All rights reserved.
//

#import "deCartaXYInteger.h"


@implementation deCartaXYInteger
@synthesize x = _x;
@synthesize y = _y;

- (NSString *) description
{
	return [NSString stringWithFormat:@"x: %d | y: %d", self.x, self.y];
}

- (BOOL) isEqual:(id) inObj
{
	if (inObj == nil)
	{
		return NO;
	}
	
	if (![inObj isKindOfClass:[self class]])
	{
		return NO;
	}
	
	deCartaXYInteger *obj = inObj;
	
	if (obj.x == self.x && obj.y == self.y)
	{
		return YES;
	}
	
	return NO;
}

-(id) initWithXi:(int)x andYi:(int)y
{
	self=[super init];
    if(self){
		
		self.x=x;
		self.y=y;
	}
	return self;
}

- (NSUInteger)hash{
	unsigned int h=3;
	h=29*h+self.x;
	h=29*h+self.y;
	return h;
}

-(id) copyWithZone:(NSZone *)zone
{
	deCartaXYInteger * xy=[[deCartaXYInteger allocWithZone:zone] init];
	xy.x=self.x;
	xy.y=self.y;
	return xy;
}


+(id)XYWithX:(int)x andY:(int)y{
	return [[[deCartaXYInteger alloc] initWithXi:x andYi:y] autorelease];
}

@end
