//
//  deCartaBoundingBox.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaBoundingBox.h"


@implementation deCartaBoundingBox

@synthesize maxPosition = _maxPosition;
@synthesize minPosition = _minPosition;

-(id)init{
	self=[super init];
    if(self){
	}
	return self;
}

- (id) initWithMin:(deCartaPosition *) min andMax:(deCartaPosition *) max
{
	self=[super init];
    if (self)
	{
		self.minPosition = min;
		self.maxPosition = max;
	}
	
	return self;
}

- (void) dealloc
{
	[_minPosition release];
	[_maxPosition release];
	[super dealloc];
}

- (deCartaPosition *) getCenterPosition
{
	double centerLat = [self.maxPosition lat] - (([self.maxPosition lat] - [self.minPosition lat]) / 2);
	double centerLon = [self.maxPosition lon] - (([self.maxPosition lon] - [self.minPosition lon]) / 2);
	return [[[deCartaPosition alloc] initWithLat:centerLat andLon:centerLon] autorelease];
}

- (BOOL) contains:(deCartaPosition *) pos
{
	if ([pos lat] > [self.minPosition lat] && [pos lon] > [self.minPosition lon] &&
		[pos lat] < [self.maxPosition lat] && [pos lon] < [self.maxPosition lon])
	{
		return YES;
	}
	
	return NO;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@" min: %@ max: %@", self.minPosition, self.maxPosition];
}

@end