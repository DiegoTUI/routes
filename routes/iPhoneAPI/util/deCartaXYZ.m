//
//  deCartaXYZ.m
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaXYZ.h"


@implementation deCartaXYZ
@synthesize x=_x;
@synthesize y=_y;
@synthesize z=_z;
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
	
	deCartaXYZ *obj = inObj;
	
	if (obj.x == self.x && obj.y == self.y && obj.z==self.z)
	{
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hash{
	unsigned int h=3;
	h=29*h+_x;
	h=29*h+_y;
	h=29*h+_z;
	return h;
}

-(id) copyWithZone:(NSZone *)zone
{
	deCartaXYZ * xyz=[[deCartaXYZ allocWithZone:zone] init];
	xyz.x=self.x;
	xyz.y=self.y;
	xyz.z=self.z;
	return xyz;
}
	
-(id)initWithX:(int)x andY:(int)y andZ:(int)z{
	self=[super init];
    if(self){
		
		self.x=x;
		self.y=y;
		self.z=z;
	}
	return self;
}

+(id)XYZWithX:(int)x andY:(int)y andZ:(int)z{
    return [[[deCartaXYZ alloc] initWithX:x andY:y andZ:z] autorelease];
}

-(NSString *)description{
	return [NSString stringWithFormat:@"%d_%d_%d",_x,_y,_z];
}
	
@end
