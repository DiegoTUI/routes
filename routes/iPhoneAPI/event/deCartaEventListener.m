//
//  deCartaEventListener.m
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaEventListener.h"


@implementation deCartaEventListener
@synthesize callback=_callback;

-(id)initWithCallback:(CallbackFunction)inCallback{
	self=[super init];
    if(self){
		_callback=[inCallback copy];
	}
	
	return self;
	
}

+(id)eventListenerWithCallback:(CallbackFunction)inCallback{
	return [[[deCartaEventListener alloc] initWithCallback:inCallback] autorelease];
}

-(void)dealloc{
	[_callback release];
	[super dealloc];
}

@end
