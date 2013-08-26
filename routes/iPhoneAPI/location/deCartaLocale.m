//
//  deCartaLocale.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaLocale.h"

@implementation deCartaLocale
@synthesize countryCode = _countryCode;
@synthesize languageCode = _languageCode;


- (id) initWithCountryCode:(NSString *) inCountry andLanguageCode:(NSString *) inLanguage
{
	if ((self = [super init])!=nil)
	{
		self.countryCode = inCountry;
		self.languageCode = inLanguage;
	}
	
	return self;
}

- (void) dealloc
{
	[_countryCode release];
	[_languageCode release];
	[super dealloc];
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
	
	deCartaLocale *obj = inObj;
	
	if ([obj.countryCode isEqualToString:self.countryCode] && [obj.languageCode isEqualToString:self.languageCode])
	{
		return YES;
	}
	
	return NO;
}

@end