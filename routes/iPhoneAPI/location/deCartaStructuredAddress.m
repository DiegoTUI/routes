//
//  deCartaStructuredAddress.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaStructuredAddress.h"


@implementation deCartaStructuredAddress

@synthesize buildingNumber = _buildingNumber;
@synthesize street = _street;
@synthesize countrySubdivision = _countrySubdivision;
@synthesize countrySecondarySubdivision = _countrySecondarySubdivision;
@synthesize municipality = _municipality;
@synthesize postalCode = _postalCode;
@synthesize municipalitySubdivision = _municipalitySubdivision;
@synthesize postedSpeedLimit = _postedSpeedLimit;

-(id)init{
	self=[super init];
    if(self){
	}
	return self;
	
}

- (NSString *) nvl:(NSString *) inValue
{
	return (inValue == nil) ? @"" : inValue;
}

- (NSString *) description
{
	return  [self formatAddressWithLineDelim:@" " fldDelim:@" "];
}

-(BOOL)isCompleteAddress{
	return [_buildingNumber length]>0 && [_street length]>0 && [_municipality length]>0 && [_countrySubdivision length]>0;
}

-(NSString *)formatAddress:(NSString *)delim{
    return [self formatAddressWithLineDelim:delim fldDelim:@" "];
}
    
-(NSString *)formatAddressWithLineDelim:(NSString *)lineDelim fldDelim:(NSString *)fldDelim{
	if(fldDelim==nil) fldDelim=@" ";
    
    NSMutableString * str=[NSMutableString stringWithCapacity:100];
    if([_street length]>0){
        if([_buildingNumber length]>0){
            [str appendString:_buildingNumber];
            [str appendString:@" "];
        }
        [str appendString:_street];
        
        if([_municipality length]>0 || [_countrySubdivision length]>0 || [_postalCode length]>0){
            [str appendString:lineDelim];
        }
    }
    
    
    NSString * strPre=@"";
    if([_municipalitySubdivision length]>0){
        [str appendString:_municipalitySubdivision];
        [str appendString:fldDelim];
        strPre=_municipalitySubdivision;
    }
    
    if([_municipality length]>0 && [_municipality caseInsensitiveCompare:strPre]!=NSOrderedSame){
        [str appendString:_municipality];
        [str appendString:fldDelim];
        strPre=_municipality;
    } 
    
    if([_countrySecondarySubdivision length]>0 
       && [_municipality length]==0
       && [_countrySecondarySubdivision caseInsensitiveCompare:strPre]!=NSOrderedSame){
        [str appendString:_countrySecondarySubdivision];
        [str appendString:fldDelim];
        strPre=_countrySecondarySubdivision;
    }
    
    if([_countrySubdivision length]>0 && [_countrySubdivision caseInsensitiveCompare:strPre]!=NSOrderedSame){
        [str appendString:_countrySubdivision];
        [str appendString:fldDelim];
        //strPre=_countrySubdivision;
    }
    
    if([_postalCode length]>0){
        [str appendString:_postalCode];
    }
    
    if([fldDelim length]>0 && [[str substringFromIndex:[str length]-[fldDelim length]] compare:fldDelim]==NSOrderedSame){
        [str replaceCharactersInRange:NSMakeRange([str length]-[fldDelim length], [fldDelim length]) withString:@""];
    }
    return str;
}

- (void) dealloc
{
	[_buildingNumber release];
	[_street release];
	[_countrySubdivision release];
	[_countrySecondarySubdivision release];
	[_municipality release];
	[_postalCode release];
	[_municipalitySubdivision release];
	[_postedSpeedLimit release];
	[super dealloc];
}
@end