//
//  deCartaFreeFormAddress.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaFreeFormAddress.h"


@implementation deCartaFreeFormAddress
@synthesize freeFormAddress = _freeFormAddress;

- (id) initWithString:(NSString *) inAddress
{
	self=[super init];
    if(self){
		self.freeFormAddress = inAddress;
	}
	
	return self;
}

- (void) dealloc
{
	[_freeFormAddress release];
	[super dealloc];
}

- (NSString *) description
{
	return self.freeFormAddress;
}

@end
