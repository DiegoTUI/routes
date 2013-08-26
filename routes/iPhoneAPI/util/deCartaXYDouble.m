//
//  deCartaXYDouble.m
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaXYDouble.h"


@implementation deCartaXYDouble
@synthesize x=_x;
@synthesize y=_y;

- (NSString *) description
{
	return [NSString stringWithFormat:@"x: %f | y: %f", self.x, self.y];
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
	
	deCartaXYDouble *obj = inObj;
	
	if (obj.x == self.x && obj.y == self.y)
	{
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hash{
	unsigned int h = 7;
	int * intX=(int *)&_x;
	int * intY=(int *)&_y;
	h = 97 * h + intY[0] ^ intY[1];
	h = 97 * h + intX[0] ^ intX[1];
	return h;
}

-(id) initWithXd:(double)x andYd:(double)y
{
	self=[super init];
    if(self){
		
		self.x=x;
		self.y=y;
	}
	return self;
}

+(id)XYWithX:(double)x andY:(double)y{
	return [[[deCartaXYDouble alloc] initWithXd:x andYd:y] autorelease];
}
@end
