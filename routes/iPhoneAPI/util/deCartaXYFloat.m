//
//  deCartaXYFloat.m
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaXYFloat.h"


@implementation deCartaXYFloat
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
	
	deCartaXYFloat *obj = inObj;
	
	if (obj.x == self.x && obj.y == self.y)
	{
		return YES;
	}
	
	return NO;
}

-(id)initWithXf:(float)x andYf:(float)y
{
	self=[super init];
    if(self){
		
		self.x=x;
		self.y=y;
	}
	return self;
}

+(id)XYWithX:(float)x andY:(float)y{
	return [[[deCartaXYFloat alloc] initWithXf:x andYf:y] autorelease];
}

@end
