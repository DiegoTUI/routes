//
//  deCartaAddress.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaAddress.h"


@implementation deCartaAddress
@synthesize locale = _locale;

-(id)init{
	self=[super init];
    if(self){
		deCartaLocale *newLocale = [[deCartaLocale alloc] initWithCountryCode:@"US" andLanguageCode:@"en"];
		self.locale = newLocale;
		[newLocale release];
	}
	return self;
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
	
	deCartaAddress *obj = inObj;
	
	if ([obj.locale isEqual:self.locale])
	{
		return YES;
	}
	
	return NO;
}

- (void) dealloc
{
	[_locale release];
	[super dealloc];
}
@end

