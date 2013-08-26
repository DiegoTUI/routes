//
//  deCartaXMLProcessor.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//+

#import "deCartaXMLProcessor.h"
#import "deCartaRouteInstruction.h"
#import "deCartaConfig.h"
#import "deCartaGlobals.h"
#import "deCartaLogger.h"

#define FOOTER @"</xls:Request></xls:XLS>"
#define REQUEST_ID 10

@interface deCartaXMLProcessor (Private)
//+ (const xmlChar *)_nodeValue:(xmlTextReaderPtr)reader readReturnInt:(int *)readReturnInt;
+ (NSString *)_localName:(xmlTextReaderPtr)reader;
+ (NSString *)_nodeValue:(xmlTextReaderPtr)reader readReturnInt:(int *)readReturnInt;
+ (NSString *) _attributeWithName:(NSString *) name reader:(xmlTextReaderPtr)reader;
+ (NSString *) _attributeAtIndex:(int) index reader:(xmlTextReaderPtr)reader;
@end



@implementation deCartaXMLProcessor


+ (NSString *) getHeader:(NSString *) methodName sessionId:(int)sessionId maxResponses:(int)maxResponses 
{
	
	NSMutableString * header = [NSMutableString string];
	[header appendString:@"<xls:XLS version=\"1\" xls:lang=\"en\" xmlns:xls=\"http://www.opengis.net/xls\" xmlns:gml=\"http://www.opengis.net/gml\""];
	if ([g_config.REL length] > 0) {
		[header appendFormat:@" rel=\"%@\"",g_config.REL];
	}
	[header appendFormat:@"><xls:RequestHeader clientName=\"%@\"",g_config.clientName];
	[header appendFormat:@" sessionID=\"%d\"",sessionId];
	[header appendFormat:@" clientPassword=\"%@\"",g_config.clientPassword];
	[header appendFormat:@" clientAPI='iphone' configuration=\"%@\"",g_scale>1?g_config.configuration_high_res:g_config.configuration_default];
	[header appendFormat:@"/><xls:Request maximumResponses=\"%d\"",maxResponses];
	[header appendFormat:@" version=\"1.0\" requestID=\"%d\" methodName=\"%@\">",REQUEST_ID,methodName];
	return header;
	
}

+ (NSData *) geocodeRequest:(deCartaAddress *) address returnFreeFormAddress:(BOOL)returnFreeFormAddress
{
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:[deCartaXMLProcessor getHeader:@"GeocodeRequest" sessionId:g_config.STATELESS_SESSION_ID maxResponses:5]];
	[xml appendFormat:@"<xls:GeocodeRequest returnFreeForm =\"%@\">",returnFreeFormAddress?@"true":@"false"];
	[xml appendFormat:@"<xls:Address countryCode=\"%@\"",address.locale.countryCode];
	[xml appendFormat:@" language=\"%@\">",[address.locale.languageCode uppercaseString]];
	
	if ([address isKindOfClass:[deCartaStructuredAddress class]]) {
		deCartaStructuredAddress * sa=(deCartaStructuredAddress *)address;
		
		if(sa.street!=nil && ![[sa.street stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqual:@""]){
			[xml appendString:@"<xls:StreetAddress>"];
			if (sa.buildingNumber != nil){
				NSString * bn=[sa.buildingNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if(![bn isEqual:@""]){
					[xml appendFormat:@"<xls:Building number=\"%@\"/>",bn];
				}
			}
			[xml appendFormat:@"<xls:Street>%@</xls:Street>",[sa.street stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]; 
			[xml appendString:@"</xls:StreetAddress>"];
		}
		
		if (sa.countrySubdivision != nil){
			NSString * cs=[sa.countrySubdivision stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if(![cs isEqual:@""]){
				[xml appendFormat:@"<xls:Place type=\"CountrySubdivision\">%@</xls:Place>",cs];
				
			}
		}
		if (sa.countrySecondarySubdivision != nil){
			NSString * css=[sa.countrySecondarySubdivision stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if(![css isEqual:@""]){
				[xml appendFormat:@"<xls:Place type=\"CountrySecondarySubdivision\">%@</xls:Place>",css];
				
			}
		}
		if (sa.municipality != nil){
			NSString * m=[sa.municipality stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if(![m isEqual:@""]){
				[xml appendFormat:@"<xls:Place type=\"Municipality\">%@</xls:Place>",m];
				
			}
		}
		if (sa.municipalitySubdivision != nil){
			NSString * ms=[sa.municipalitySubdivision stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if(![ms isEqual:@""]){
				[xml appendFormat:@"<xls:Place type=\"MunicipalitySubdivision\">%@</xls:Place>",ms];
				
			}
		}
		if (sa.postalCode != nil){
			NSString * pc=[sa.postalCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if(![pc isEqual:@""]){
				[xml appendFormat:@"<xls:PostalCode>%@</xls:PostalCode>",pc];
				
			}
		}
	} else if ([address isKindOfClass:[deCartaFreeFormAddress class]]) {
		[xml appendFormat:@"<xls:freeFormAddress>%@</xls:freeFormAddress>",address];
		
	}
	
	[xml appendString:@"</xls:Address></xls:GeocodeRequest>"];
	[xml appendString:FOOTER];
	NSData * data=[xml dataUsingEncoding:NSUTF8StringEncoding];
	return data;
}

+ (NSArray *) processGeocode:(NSData *) xmlData returnFreeFormAddress:(BOOL)returnFreeFormAddress
{
	xmlTextReaderPtr _reader = xmlReaderForMemory([xmlData bytes], [xmlData length], nil , nil, XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	int _readReturnInt=-1;
	if (!_reader)
	{
		return nil;
	}
	
	NSMutableArray *results = [NSMutableArray array];
	deCartaGeocodeResponse *curGeocodeResponse = nil;
	BOOL insidePoint=NO;
	
	@try {
		while (true)
		{
			_readReturnInt = xmlTextReaderRead(_reader);
			if (_readReturnInt != 1)
			{
				break;
			}
			
			if (xmlTextReaderNodeType(_reader) == XML_READER_TYPE_ELEMENT)
			{
				NSString *tag = [deCartaXMLProcessor _localName:_reader];
				if ([tag caseInsensitiveCompare:@"Error"] == NSOrderedSame)
				{
					NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
					[deCartaLogger warn:value];
					@throw [NSException exceptionWithName:@"WebServicesFailure" reason:value userInfo:nil];
				}
				else if ([tag caseInsensitiveCompare:@"GeocodedAddress"] == NSOrderedSame)
				{
					
					curGeocodeResponse = [[[deCartaGeocodeResponse alloc] init] autorelease];
					if(returnFreeFormAddress){
						curGeocodeResponse.address=[[[deCartaFreeFormAddress alloc] initWithString:@""] autorelease] ;
					}else{
						curGeocodeResponse.address=[[[deCartaStructuredAddress alloc] init] autorelease];
					}
				}else if ([tag caseInsensitiveCompare:@"Point"]==NSOrderedSame) {
					insidePoint=TRUE;
				}else if([tag caseInsensitiveCompare:@"Address"] == NSOrderedSame){
					NSString * countryCode=[deCartaXMLProcessor _attributeWithName:@"countryCode" reader:_reader];
					if([countryCode length]>0){
						curGeocodeResponse.address.locale.countryCode=countryCode;
					}
				}else if ([tag caseInsensitiveCompare:@"GeocodeMatchCode"] == NSOrderedSame)
				{
					if (xmlTextReaderHasAttributes(_reader))
					{
						NSString *accuracy = [deCartaXMLProcessor _attributeWithName:@"accuracy" reader:_reader];
						NSString *matchType = [deCartaXMLProcessor _attributeWithName:@"matchType" reader:_reader];
						if ([accuracy length]>0)
						{
							curGeocodeResponse.accuracy = [accuracy doubleValue];
						}
						
						if ([matchType length]>0)
						{
							curGeocodeResponse.matchType = matchType;
						}
					}
				}
				else if ([tag caseInsensitiveCompare:@"Place"] == NSOrderedSame && !returnFreeFormAddress)
				{
					if (xmlTextReaderHasAttributes(_reader))
					{
						NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
						if ([value caseInsensitiveCompare:@"Municipality"] == NSOrderedSame)
						{
							((deCartaStructuredAddress *)curGeocodeResponse.address).municipality = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
                        else if ([value caseInsensitiveCompare:@"MunicipalitySubdivision"] == NSOrderedSame)
						{
							((deCartaStructuredAddress *)curGeocodeResponse.address).municipalitySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
						else if ([value caseInsensitiveCompare:@"CountrySubdivision"] == NSOrderedSame)
						{
							((deCartaStructuredAddress *)curGeocodeResponse.address).countrySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
						else if ([value caseInsensitiveCompare:@"CountrySecondarySubdivision"] == NSOrderedSame)
						{
							((deCartaStructuredAddress *)curGeocodeResponse.address).countrySecondarySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
					}
				}
				
				
				
				else if (insidePoint && [tag caseInsensitiveCompare:@"pos"] == NSOrderedSame)
				{
					deCartaPosition *pos = [[[deCartaPosition alloc] initWithString: [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt]] autorelease];
					curGeocodeResponse.position = pos;
					
				}
				else if([tag caseInsensitiveCompare:@"freeFormAddress"]==NSOrderedSame && returnFreeFormAddress){
					((deCartaFreeFormAddress *)curGeocodeResponse.address).freeFormAddress=[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				else if(!returnFreeFormAddress){
					if ([tag caseInsensitiveCompare:@"Building"] == NSOrderedSame)
					{
						if (xmlTextReaderHasAttributes(_reader))
						{
							NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
							((deCartaStructuredAddress *)curGeocodeResponse.address).buildingNumber = value;
						}
					}
					else if ([tag caseInsensitiveCompare:@"Street"] == NSOrderedSame)
					{
						((deCartaStructuredAddress *)curGeocodeResponse.address).street = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
					}
					
					else if ([tag caseInsensitiveCompare:@"PostalCode"] == NSOrderedSame)
					{
						((deCartaStructuredAddress *)curGeocodeResponse.address).postalCode = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
					}
				}
				
			}else if (xmlTextReaderNodeType(_reader)==XML_READER_TYPE_END_ELEMENT) {
				NSString * tag=[deCartaXMLProcessor _localName:_reader];
				if ([tag caseInsensitiveCompare:@"GeocodedAddress"]==NSOrderedSame) {
					if (curGeocodeResponse)
					{
						[results addObject:curGeocodeResponse];
						//[curGeocodeResponse release];
					}
					
				}else if ([tag caseInsensitiveCompare:@"Point"]==NSOrderedSame) {
					insidePoint=FALSE;
				}
			}
			
			
			
			if (_readReturnInt != 1)
				break;
		}
	}
	@catch (NSException * e) {
		@throw e;
	}
	@finally {
		xmlFreeTextReader(_reader);
	}
	
	return results; //[results autorelease];
}

+ (NSData *) reverseGeocodeRequest:(deCartaPosition *) pos
{
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:[deCartaXMLProcessor getHeader:@"ReverseGeocodeRequest" sessionId:g_config.STATELESS_SESSION_ID maxResponses:10]];
	[xml appendString:@"<xls:ReverseGeocodeRequest><xls:Position><gml:Point><gml:pos>"];
	[xml appendFormat:@"%@", pos];
	[xml appendString:@"</gml:pos></gml:Point></xls:Position><xls:ReverseGeocodePreference>StreetAddress</xls:ReverseGeocodePreference></xls:ReverseGeocodeRequest>"];
	[xml appendString:FOOTER];
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	
	return data;
}

+ (deCartaStructuredAddress *) processReverseGeocode:(NSData *) xmlData
{
	xmlTextReaderPtr _reader = xmlReaderForMemory([xmlData bytes], [xmlData length], nil , nil, XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	int _readReturnInt=-1;
	if (!_reader)
	{
		return nil;
	}
	
	deCartaStructuredAddress *address = [[[deCartaStructuredAddress alloc] init] autorelease];
	
	@try {
		while (true)
		{
			_readReturnInt = xmlTextReaderRead(_reader);
			if (_readReturnInt != 1)
			{
				break;
			}
			
			if (xmlTextReaderNodeType(_reader) != XML_READER_TYPE_ELEMENT)
			{
				continue;
			}
			
			NSString *tag = [deCartaXMLProcessor _localName:_reader];
			if ([tag caseInsensitiveCompare:@"Error"] == NSOrderedSame)
			{
				NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
				[deCartaLogger warn:value];
				@throw [NSException exceptionWithName:@"WebServicesFailure" reason:value userInfo:nil];
				
			}
			else if ([tag caseInsensitiveCompare:@"Building"] == NSOrderedSame)
			{
				if (xmlTextReaderHasAttributes(_reader))
				{
					NSString *value = [deCartaXMLProcessor _attributeWithName:@"number" reader:_reader];
					address.buildingNumber = value;
				}
			}
			else if ([tag caseInsensitiveCompare:@"Street"] == NSOrderedSame)
			{
				address.postedSpeedLimit=[deCartaXMLProcessor _attributeWithName:@"speedLimit" reader:_reader];
				address.street = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
			}
			else if ([tag caseInsensitiveCompare:@"Place"] == NSOrderedSame)
			{
				if (xmlTextReaderHasAttributes(_reader))
				{
					NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
					if ([value caseInsensitiveCompare:@"Municipality"] == NSOrderedSame)
					{
						address.municipality = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
					}
                    else if ([value caseInsensitiveCompare:@"MunicipalitySubdivision"] == NSOrderedSame)
                    {
                        address.municipalitySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
                    }
					else if ([value caseInsensitiveCompare:@"CountrySubdivision"] == NSOrderedSame)
					{
						address.countrySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
					}
					else if ([value caseInsensitiveCompare:@"CountrySecondarySubdivision"] == NSOrderedSame)
					{
						address.countrySecondarySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
					}
				}
			}
			else if ([tag caseInsensitiveCompare:@"PostalCode"] == NSOrderedSame)
			{
				address.postalCode = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
			}
			
			if (_readReturnInt != 1)
				break;
		}
	}
	@catch (NSException * e) {
		@throw e;
	}
	@finally {
		xmlFreeTextReader(_reader);
	}
	
	return address; //[address autorelease];
}

+ (NSData *) poiRequest:(deCartaPOISearchCriteria *) criteria
{
	NSMutableString *xml = [NSMutableString string];
	[xml appendString:[deCartaXMLProcessor getHeader:@"DirectoryRequest" sessionId:g_config.STATELESS_SESSION_ID maxResponses:criteria.maximumResponses]];
	[xml appendString:@"<xls:DirectoryRequest"];
	if ([criteria.database length]>0)
	{
		[xml appendFormat:@" database=\"%@\"",criteria.database];
		
	}
	if([criteria.sortCriteria length]>0){
		[xml appendFormat:@" sortDirection=\"%@\"",criteria.sortDirection];
		[xml appendFormat:@" sortCriteria=\"%@\"",criteria.sortCriteria];
	}
	if([criteria.rankCriteria length]>0 && [criteria.database length]>0){
		[xml appendFormat:@" rankCriteria='%@'",criteria.rankCriteria];
		
	}
	if (criteria.allowAggregates) {
		[xml appendFormat:@" allowAggregates='true'"];
	}
	[xml appendString:@">"];
    
    if(criteria.routeId!=nil){
        // Build the POILocation with nested elements
        [xml appendString:@"<xls:POILocation><xls:NearRoute>"];
        if([criteria.corridorType isEqualToString:@"distance"]){
            [xml appendFormat:@"<xls:distance value='%f' uom='M'/>",criteria.distance];
        } else if([criteria.corridorType isEqualToString:@"euclideanDistance"]){
            [xml appendFormat:@"<xls:euclideanDistance value='%f' uom='M'/>",criteria.distance];
        } else {
            // TODO need to build in better
            [xml appendFormat:@"<xls:drivetime>P0DT%dH%dM%dS</xls:drivetime>",criteria.duration/3600,(criteria.duration%3600)/60,(criteria.duration%3600)%60];
        }
        [xml appendFormat:@"<xls:RouteID>%@</xls:RouteID>",criteria.routeId];
        [xml appendString:@"</xls:NearRoute></xls:POILocation>"];
        
    }else{
        [xml appendString:@"<xls:POILocation><xls:WithinDistance><xls:POI ID=\"1\"><gml:Point><gml:pos>"];
        [xml appendString:[criteria.centerPosition description]];
        [xml appendFormat:@"</gml:pos></gml:Point></xls:POI><xls:MaximumDistance value=\"%f\" uom=\"M\"/></xls:WithinDistance></xls:POILocation>",criteria.radius];
    }
    
    [xml appendFormat:@"<xls:POIProperties><xls:POIProperty name=\"%@\" value=\"%@\"/>",criteria.queryType,criteria.queryString];
	if([criteria.queryStringAdj length]>0){
		[xml appendFormat:@"<xls:POIProperty name=\"%@\" value=\"%@\"/>",criteria.queryTypeAdj,criteria.queryStringAdj];
		
	}
	[xml appendString:@"</xls:POIProperties></xls:DirectoryRequest>"];
	[xml appendString:FOOTER];
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	//[xml release];
	return data;
}

+ (NSArray *) processPOI:(NSData *) xmlData
{
	xmlTextReaderPtr _reader = xmlReaderForMemory([xmlData bytes], [xmlData length], nil , nil, XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	int _readReturnInt=-1;
	if (!_reader)
	{
		return nil;
	}
	
	NSMutableArray *pois = [NSMutableArray array];
	deCartaPOI *curPOI = nil;
	deCartaStructuredAddress *curStructuredAddr = nil;
	deCartaFreeFormAddress *curFreeFormAddr=nil;
	
	@try {
		while (true)
		{
			_readReturnInt = xmlTextReaderRead(_reader);
			if (_readReturnInt != 1)
			{
				break;
			}
			
			if (xmlTextReaderNodeType(_reader) == XML_READER_TYPE_ELEMENT)
			{
				NSString *tag = [deCartaXMLProcessor _localName:_reader];
				if ([tag caseInsensitiveCompare:@"Error"] == NSOrderedSame)
				{
					NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
					[deCartaLogger warn:value];
					@throw [NSException exceptionWithName:@"WebServicesFailure" reason:value userInfo:nil];
				}
				else if ([tag caseInsensitiveCompare:@"POIContext"] == NSOrderedSame)
				{
                    curPOI = [[[deCartaPOI alloc] init] autorelease];
                }
                else if ([tag caseInsensitiveCompare:@"POI"] == NSOrderedSame)
				{
					NSString *phoneNumber = [deCartaXMLProcessor _attributeWithName:@"phoneNumber" reader:_reader];
					NSString *name = [deCartaXMLProcessor _attributeWithName:@"POIName" reader:_reader];
					curPOI.phoneNumber = phoneNumber;
					curPOI.name = name;
				}
                else if ([tag caseInsensitiveCompare:@"Address"] == NSOrderedSame)
				{
                    NSString *countryCode=[deCartaXMLProcessor _attributeWithName:@"countryCode" reader:_reader];
                    curStructuredAddr = [[[deCartaStructuredAddress alloc] init] autorelease];
                    curFreeFormAddr = [[[deCartaFreeFormAddress alloc] initWithString:nil] autorelease];
                    if([countryCode length]>0){
                        curStructuredAddr.locale.countryCode=countryCode;
                        curFreeFormAddr.locale.countryCode=countryCode;
                    }
					

                }
				else if ([tag caseInsensitiveCompare:@"Building"] == NSOrderedSame)
				{
					if (xmlTextReaderHasAttributes(_reader))
					{
						NSString *value = [deCartaXMLProcessor _attributeWithName:@"number" reader:_reader];
						curStructuredAddr.buildingNumber = value;
					}
				}
				else if([tag caseInsensitiveCompare:@"Distance"] == NSOrderedSame){
					NSString *onRoute=[deCartaXMLProcessor _attributeWithName:@"onRoute" reader:_reader];
                    double dist=[[deCartaXMLProcessor _attributeWithName:@"value" reader:_reader] doubleValue];
					if(onRoute==nil || [onRoute length]==0){
                        curPOI.distance=[[[deCartaLength alloc] initWithDistance:dist andUOM:M] autorelease];
                    }else{
                        if([onRoute caseInsensitiveCompare:@"true"]==NSOrderedSame){
                            curPOI.distanceOnRoute=[[[deCartaLength alloc] initWithDistance:dist andUOM:M] autorelease];
                        }else{
                            curPOI.distanceOffRoute=[[[deCartaLength alloc] initWithDistance:dist andUOM:M] autorelease];
                        }
                    }
                    
				}
                else if([tag caseInsensitiveCompare:@"Duration"]==NSOrderedSame){
                    NSString *onRoute=[deCartaXMLProcessor _attributeWithName:@"onRoute" reader:_reader];
                    NSString *duration=[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
                    NSRange rangeT=[duration rangeOfString:@"T"];
                    NSRange rangeH=[duration rangeOfString:@"H"];
                    NSRange rangeM=[duration rangeOfString:@"M"];
                    NSRange rangeS=[duration rangeOfString:@"S"];
                    int h=[[duration substringWithRange:NSMakeRange(rangeT.location+1, rangeH.location-rangeT.location-1)] intValue];
                    int m=[[duration substringWithRange:NSMakeRange(rangeH.location+1, rangeM.location-rangeH.location-1)] intValue];
                    int s=[[duration substringWithRange:NSMakeRange(rangeM.location+1, rangeS.location-rangeM.location-1)] intValue];
                    int total=3600*h+60*m+s;
                    if([onRoute caseInsensitiveCompare:@"true"]==NSOrderedSame){
                        curPOI.durationOnRoute=total;
                    }else{
                        curPOI.durationOffRoute=total;
                    }
                    
                    
                }
				else if ([tag caseInsensitiveCompare:@"Place"] == NSOrderedSame)
				{
					if (xmlTextReaderHasAttributes(_reader))
					{
						NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
						if ([value caseInsensitiveCompare:@"Municipality"] == NSOrderedSame)
						{
							curStructuredAddr.municipality = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
						else if ([value caseInsensitiveCompare:@"CountrySubdivision"] == NSOrderedSame)
						{
							curStructuredAddr.countrySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
						else if ([value caseInsensitiveCompare:@"CountrySecondarySubdivision"] == NSOrderedSame)
						{
							curStructuredAddr.countrySecondarySubdivision = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
						}
					}
				}
				else if([tag caseInsensitiveCompare:@"freeFormAddress"] == NSOrderedSame){
					curFreeFormAddr.freeFormAddress=[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				else if ([tag caseInsensitiveCompare:@"Street"] == NSOrderedSame)
				{
					curStructuredAddr.street = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				
				else if ([tag caseInsensitiveCompare:@"PostalCode"] == NSOrderedSame)
				{
					curStructuredAddr.postalCode = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				else if ([tag caseInsensitiveCompare:@"pos"] == NSOrderedSame)
				{
					deCartaPosition *pos = [[[deCartaPosition alloc] initWithString:[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt]] autorelease];
					curPOI.position = pos;
				}
				
				
			}else if(xmlTextReaderNodeType(_reader)==XML_READER_TYPE_END_ELEMENT){
				NSString *tag = [deCartaXMLProcessor _localName:_reader];
				
				if ([tag caseInsensitiveCompare:@"POIContext"]==NSOrderedSame) {
					if(![curStructuredAddr isCompleteAddress] && [curFreeFormAddr.freeFormAddress length]>0){
						curPOI.address=curFreeFormAddr;
					}else{
						curPOI.address=curStructuredAddr;
					}
					
					[pois addObject:curPOI];
					
				}
				
				
			}
			if (_readReturnInt != 1)
				break;
			
		}
	}
	@catch (NSException * e) {
		@throw e;
	}
	@finally {
		xmlFreeTextReader(_reader);
		
	}
	
	return pois;//[pois autorelease];
}

+ (NSData *) routeRequest:(NSArray *) pos prefs:(deCartaRoutePreference *) prefs
{
	NSMutableString *xml = [NSMutableString string];
	NSMutableString *geo = [NSMutableString string];
	NSMutableString *inst= [NSMutableString string];
	NSMutableString *optimized= [NSMutableString string];
	if (prefs.returnGeometry)
	{
		[geo appendString:@"<xls:RouteGeometryRequest"];
		//[geo appendFormat:@" resolution='%d'", prefs.generalizationLevel];
		[geo appendFormat:@" returnRouteIDOnly='%@'></xls:RouteGeometryRequest>",prefs.returnRouteIdOnly?@"true":@"false"];
		
	}
	else
	{
		[geo appendString:@""];
	}
	
	if (prefs.returnInstructions)
	{
		NSString * rules=[prefs.rules length]>0?[NSString stringWithFormat:@" rules='%@'",prefs.rules]:@"";
		[inst appendFormat:@"<xls:RouteInstructionsRequest providePoint='true'%@/>",rules];
	}
	else
	{
		[inst appendString:@""];
	}
	
	if (prefs.optimized)
	{
		[optimized appendString:@" optimize=\"true\""];
	}
	else
	{
		[optimized appendString:@""];
	}
    
    NSInteger countRoutePoints = [pos count];
	
	[xml appendString:[deCartaXMLProcessor getHeader:@"DetermineRouteRequest" sessionId:g_config.STATELESS_SESSION_ID maxResponses:100]];
	[xml appendFormat:@"<xls:DetermineRouteRequest routeQueryType=\"%@\" provideRouteHandle='true'",prefs.routeQueryType];
	[xml appendFormat:@" distanceUnit='%@'>",prefs.distanceType];
	[xml appendFormat:@"<xls:RoutePlan %@>",optimized];
	[xml appendFormat:@"<xls:RoutePreference>%@</xls:RoutePreference><xls:WayPointList>",prefs.style];
	[xml appendString:@"<xls:StartPoint><xls:Position><gml:Point><gml:pos>"];
	[xml appendFormat:@"%@", [pos objectAtIndex:0]];
	[xml appendString:@"</gml:pos></gml:Point></xls:Position>"];
	[xml appendString:@"</xls:StartPoint>"];
    for (int i=1; i<(countRoutePoints-1); i++) {
        [xml appendString:@"<xls:ViaPoint><xls:Position><gml:Point><gml:pos>"];
        [xml appendFormat:@"%@",[pos objectAtIndex:i]];
        [xml appendString:@"</gml:pos></gml:Point></xls:Position></xls:ViaPoint>"];
    }
    [xml appendString:@"<xls:EndPoint><xls:Position><gml:Point><gml:pos>"];
	[xml appendFormat:@"%@", [pos objectAtIndex:(countRoutePoints-1)]];
	[xml appendString:@"</gml:pos></gml:Point></xls:Position></xls:EndPoint>"];
	[xml appendString:@"</xls:WayPointList></xls:RoutePlan>"];
	[xml appendString:inst];
	[xml appendString:geo];
	[xml appendString:@"</xls:DetermineRouteRequest>"];
	[xml appendString:FOOTER];
	//[geo release];
	//[inst release];
	//[optimized release];
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	//[xml release];
	return data;
}

+ (deCartaRoute *) processRoute:(NSData *) xmlData
{
	xmlTextReaderPtr _reader = xmlReaderForMemory([xmlData bytes], [xmlData length], nil , nil, XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	int _readReturnInt=-1;
	if (!_reader)
	{
		return nil;
	}
	
	deCartaRoute *route = [[[deCartaRoute alloc] init] autorelease];
	deCartaRouteInstruction *curInstr = nil;
	BOOL insideGeometry = NO;
	BOOL insideSummary = NO;
	BOOL insideRouteInstruction=NO;
	@try {
		while (true)
		{
			_readReturnInt = xmlTextReaderRead(_reader);
			if (_readReturnInt != 1)
			{
				break;
			}
			
			if (xmlTextReaderNodeType(_reader) == XML_READER_TYPE_ELEMENT)
			{
				NSString *tag = [deCartaXMLProcessor _localName:_reader];
				if ([tag caseInsensitiveCompare:@"Error"] == NSOrderedSame)
				{
					NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
					[deCartaLogger warn:value];
					@throw [NSException exceptionWithName:@"WebServicesFailure" reason:value userInfo:nil];
				}
				else if([tag caseInsensitiveCompare:@"RouteHandle"] == NSOrderedSame){
					route.routeId=[deCartaXMLProcessor _attributeWithName:@"routeID" reader:_reader];
				}
				else if ([tag caseInsensitiveCompare:@"RouteSummary"] == NSOrderedSame)
				{
					insideSummary = YES;
				}
				else if (insideSummary && [tag caseInsensitiveCompare:@"TotalDistance"] == NSOrderedSame)
				{
					NSString *uom = [deCartaXMLProcessor _attributeWithName:@"uom" reader:_reader];
					NSString *value = [deCartaXMLProcessor _attributeWithName:@"value" reader:_reader];
					UOM uomE=M;
					if([uom caseInsensitiveCompare:@"MI"]==NSOrderedSame) uomE=MI;
					else if([uom caseInsensitiveCompare:@"KM"]==NSOrderedSame) uomE=KM;
					route.totalDistance = [[[deCartaLength alloc] initWithDistance:[value doubleValue] andUOM:uomE] autorelease];
				}
				else if ([tag caseInsensitiveCompare:@"RouteGeometry"] == NSOrderedSame) {
					insideGeometry=TRUE;
				}
				else if ([tag caseInsensitiveCompare:@"RouteInstruction"] == NSOrderedSame)
				{
					insideRouteInstruction=TRUE;
					
					curInstr = [[[deCartaRouteInstruction alloc] init] autorelease];
					
					NSString *tour = [deCartaXMLProcessor _attributeWithName:@"tour" reader:_reader];
					NSString *duration = [deCartaXMLProcessor _attributeWithName:@"duration" reader:_reader];
					curInstr.tour = tour;
					curInstr.duration = duration;
				}
				else if (insideRouteInstruction && [tag caseInsensitiveCompare:@"distance"] == NSOrderedSame)
				{
					NSString *uom = [deCartaXMLProcessor _attributeWithName:@"uom" reader:_reader];
					NSString *value = [deCartaXMLProcessor _attributeWithName:@"value" reader:_reader];
					UOM uomE=M;
					if([uom caseInsensitiveCompare:@"MI"]==NSOrderedSame) uomE=MI;
					else if([uom caseInsensitiveCompare:@"KM"]==NSOrderedSame) uomE=KM;
					curInstr.distance = [[[deCartaLength alloc] initWithDistance:[value doubleValue] andUOM:uomE] autorelease];
				}
				
				
				else if ([tag caseInsensitiveCompare:@"pos"] == NSOrderedSame)
				{
					deCartaPosition *pos = [[[deCartaPosition alloc] initWithString:[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt]] autorelease];
					if (insideSummary)
					{
						if (route.boundingBox.minPosition == nil)
						{
							route.boundingBox.minPosition = pos;
						}
						else
						{
							route.boundingBox.maxPosition = pos;
						}
					}
					else if(insideGeometry)
					{
						[route.routeGeometry addObject:pos];
					}
					//[pos release];
				}
				else if (insideSummary && [tag caseInsensitiveCompare:@"TotalTime"] == NSOrderedSame)
				{
					route.totalTime = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				
				
				else if (insideRouteInstruction && [tag caseInsensitiveCompare:@"Instruction"] == NSOrderedSame)
				{
					curInstr.instruction = [deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				else if(insideRouteInstruction && [tag caseInsensitiveCompare:@"Point"]==NSOrderedSame){
					NSString * value=[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
					curInstr.position=[[[deCartaPosition alloc] initWithString:value] autorelease];
				}else if ([tag caseInsensitiveCompare:@"RouteID"]==NSOrderedSame) {
					route.routeId=[deCartaXMLProcessor _nodeValue:_reader readReturnInt:&_readReturnInt];
				}
				
			}else if (xmlTextReaderNodeType(_reader)==XML_READER_TYPE_END_ELEMENT) {
				NSString * tag=[deCartaXMLProcessor _localName:_reader];
				
				if ([tag caseInsensitiveCompare:@"RouteSummary"]==NSOrderedSame) {
					insideSummary=FALSE;
				}else if([tag caseInsensitiveCompare:@"RouteGeometry"]==NSOrderedSame){
					insideGeometry=FALSE;
				}else if ([tag caseInsensitiveCompare:@"RouteInstruction"]==NSOrderedSame) {
					insideRouteInstruction=FALSE;
					[route.routeInstructions addObject:curInstr];
					//[curInstr release];
					
				}
				
				
			}
			
			
			if (_readReturnInt != 1)
				break;
		}
	}
	@catch (NSException * e) {
		@throw e;
	}
	@finally {
		xmlFreeTextReader(_reader);
	}
		
	return route; //[route autorelease];
}

+ (NSData *) ruokRequest
{
	NSMutableString *xml = [[[NSMutableString alloc] init] autorelease];
	[xml appendString:[deCartaXMLProcessor getHeader:@"RUOKRequest" sessionId:g_config.STATELESS_SESSION_ID maxResponses:10]];
	[xml appendString:@"<xls:RUOKRequest />"];
	[xml appendString:FOOTER];
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	//[xml release];
	return data;
}

+ (NSString *) processRUOK:(NSData *) xmlData
{
	xmlTextReaderPtr _reader = xmlReaderForMemory([xmlData bytes], [xmlData length], nil , nil, XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	int _readReturnInt=-1;
	if (!_reader)
	{
		return nil;
	}
	
	NSString *host = nil;
	
	@try {
		while (true)
		{
			_readReturnInt = xmlTextReaderRead(_reader);
			if (_readReturnInt != 1)
			{
				break;
			}
			
			if (xmlTextReaderNodeType(_reader) != XML_READER_TYPE_ELEMENT)
			{
				continue;
			}
			
			NSString *tag = [deCartaXMLProcessor _localName:_reader];
			if ([tag caseInsensitiveCompare:@"Error"] == NSOrderedSame)
			{
				NSString *value = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
				[deCartaLogger warn:value];
				@throw [NSException exceptionWithName:@"WebServicesFailure" reason:value userInfo:nil];
			}
			else if ([tag caseInsensitiveCompare:@"RUOKResponse"] == NSOrderedSame)
			{
				//host = [deCartaXMLProcessor _attributeAtIndex:0 reader:_reader];
                host = [deCartaXMLProcessor _attributeWithName:@"hostName" reader:_reader];
			}
			
			if (_readReturnInt != 1)
				break;
		}
	}
	@catch (NSException * e) {
		@throw e;
	}
	@finally {
		xmlFreeTextReader(_reader);
	}
	
	return host;
}

@end

@implementation deCartaXMLProcessor (Private)

/*
+ (const xmlChar *)_nodeValue:(xmlTextReaderPtr)reader readReturnInt:(int *)readReturnInt
{
	if (xmlTextReaderIsEmptyElement(reader))
		return nil;
	int nodeType = XML_READER_TYPE_NONE;
	while (true) {
		nodeType = xmlTextReaderNodeType(reader);
		if (nodeType == XML_READER_TYPE_TEXT)
			return xmlTextReaderConstValue(reader);
		if (nodeType == XML_READER_TYPE_END_ELEMENT)
			return nil;
		*readReturnInt = xmlTextReaderRead(reader);
		if (*readReturnInt != 1)
			return nil;
	}
	return nil;
}


+ (NSString *)_nodeValue:(xmlTextReaderPtr)reader readReturnInt:(int *)readReturnInt
{
	const xmlChar *nodeValue = [deCartaXMLProcessor _nodeValue:reader readReturnInt:readReturnInt];
	if (!nodeValue)
		return nil;
	return [NSString stringWithUTF8String:(const char *)nodeValue];
}*/

+ (NSString *)_localName:(xmlTextReaderPtr)reader{
	xmlChar * localName=xmlTextReaderLocalName(reader);
	NSString * ln=[NSString stringWithUTF8String:(const char*)localName];
	free(localName);
	
	return ln;
	
}

+ (NSString *)_nodeValue:(xmlTextReaderPtr)reader readReturnInt:(int *)readReturnInt
{
	if (xmlTextReaderIsEmptyElement(reader))
		return nil;
	
	const xmlChar *nodeValue=nil;
	do{
		*readReturnInt = xmlTextReaderRead(reader);
		if (*readReturnInt != 1)
			break;
		int nodeType = xmlTextReaderNodeType(reader);
		if (nodeType == XML_READER_TYPE_TEXT){
			nodeValue= xmlTextReaderConstValue(reader);
			break;
		}
		if (nodeType == XML_READER_TYPE_END_ELEMENT)
			break;
		if (nodeType == XML_READER_TYPE_ELEMENT)
			break;
		
	}while (true); 
	
	if (!nodeValue)
		return nil;
	return [NSString stringWithUTF8String:(const char *)nodeValue];
}


+ (NSString *) _attributeWithName:(NSString *) name reader:(xmlTextReaderPtr)reader
{
	xmlChar *value = xmlTextReaderGetAttribute(reader, (xmlChar *) [name UTF8String]);
	if (value)
	{
		NSString * an=[NSString stringWithUTF8String:(const char *)value];
		free(value);
		return an;
	}
	else
	{
		return nil;
	}
}

+ (NSString *) _attributeAtIndex:(int) index reader:(xmlTextReaderPtr)reader
{
	xmlChar *value = xmlTextReaderGetAttributeNo(reader, index);
	if (value)
	{
		NSString * an=[NSString stringWithUTF8String:(const char *)value];
		free(value);
		return an;
	}
	else
	{
		return nil;
	}
}


@end