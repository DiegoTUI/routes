//
//  deCartaWebServices.m
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaWebServices.h"
#import "deCartaUtil.h"
#import "deCartaLogger.h"
#import "deCartaXMLProcessor.h"

static int DEFAULT_READ_TIMEOUT=120;
static int TILE_IMAGE_READ_TIMEOUT=20;
static NSString * _host=nil;

@implementation deCartaWebServices

NSData * postViaHttpConnection(NSData * requestToSend,NSString * urlStr, int readTimeout){
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:readTimeout];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:requestToSend];
	
    [deCartaLogger debugws:requestToSend tag:@"request"];
    
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (![response isKindOfClass:[NSHTTPURLResponse class]]){
		[deCartaLogger fatal:[NSString stringWithFormat:@"WebServices postViaHttpConnection failed for urlStr:%@,requestToSend:%@",
							  urlStr,[NSString stringWithUTF8String:[requestToSend bytes]] ]];
		@throw [NSException exceptionWithName:@"NotHTTPURLResponse" reason:@"response is not kind of NSHTTPURLResponse" userInfo:nil];
	}
	
	NSHTTPURLResponse * resp=(NSHTTPURLResponse *)response;
	NSInteger statusCode = [resp statusCode];
	if(statusCode==200 && data!=nil && [data length]>0){
		[deCartaLogger debugws:data tag:@"response"];
        
        return data;
	}else if(statusCode==302){
		NSString * urlStrRedirect= [[resp allHeaderFields] objectForKey:@"Location"];
		
		[deCartaLogger info:[NSString stringWithFormat:@"WebServices postViaHttpConnection urlStr:%@,redirectUrl:%@,requestToSend:%@",
							 urlStr,urlStrRedirect,[NSString stringWithUTF8String:[requestToSend bytes]] ]];
		
		return postViaHttpConnection(requestToSend, urlStrRedirect, readTimeout);
	}else {
		@throw [NSException exceptionWithName:@"WrongResponseStatusCode" reason:[NSString stringWithFormat:@"Response invalid statusCode:%d",statusCode] userInfo:nil];
		
	}
	
}

+(NSString *) setHostViaRUOK:(NSString *) generalHost{
	NSData * ruokRequest=[deCartaXMLProcessor ruokRequest];
	NSString * urlStr=generalHost;
	NSData * bytes=postViaHttpConnection(ruokRequest, urlStr, DEFAULT_READ_TIMEOUT);
	NSString * hostL=[deCartaXMLProcessor processRUOK:bytes];
    
    NSRange portStart=[generalHost rangeOfString:@":"options:0 range:NSMakeRange([@"http://" length], [generalHost length]-[@"http://" length])];
    if(portStart.location!=NSNotFound && portStart.location>[@"http://" length]){
        NSRange portEnd=[generalHost rangeOfString:@"/openls/openls"options:0 range:NSMakeRange(portStart.location, [generalHost length]-portStart.location)];
        if(portStart.location<portEnd.location && portEnd.location!=NSNotFound){
            NSString * port=[generalHost substringWithRange:NSMakeRange(portStart.location, portEnd.location-portStart.location)];
            hostL=[hostL stringByAppendingString:port];
        }
    }
    
	hostL=[@"http://" stringByAppendingString:hostL];
	hostL=[hostL stringByAppendingString:@"/openls/openls"];
	_host=[hostL retain];
	[deCartaLogger info:[NSString stringWithFormat:@"WebServices setHostViaRUOK host:%@",_host]];
	return _host;
}

+(NSData *)getTileImage:(deCartaTile *)requestTile{
	NSString * url=[deCartaUtil composeUrl:requestTile];
	if([url length]==0) return nil;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:TILE_IMAGE_READ_TIMEOUT];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
		if(statusCode==200 && data!=nil && [data length]>0){
			return data;
		}
		[deCartaLogger warn:[NSString stringWithFormat:@"WebServices getTileImage failed,statusCode:%d,data length:%d",statusCode,[data length]]];
		return nil;
		
	}else{
		[deCartaLogger warn:[NSString stringWithFormat:@"WebServices getTileImage data length:%d,response class:%@, failed for tile:%@",[data length], [response class],requestTile]];
		return nil;
	}

}

+(NSData *) postViaHttpConnection:(NSData *)requestToSend readTimeout:(int)readTimeout{
	if([_host length]<=0){
		[deCartaLogger info:@"WebServices postViaHttpConnection host is null/empty, call setHostViaRUOK"];
		[deCartaWebServices setHostViaRUOK:g_config.host];
	}
	//NSLog(@"WebServices postViaHttpConnection request:%@",[NSString stringWithCString:[requestToSend bytes] encoding:NSUTF8StringEncoding]);
	NSData * bytes=postViaHttpConnection(requestToSend, _host, readTimeout);
	//NSLog(@"WebServices postViaHttpConnection response:%@",[NSString stringWithUTF8String:[bytes bytes]]);
	return bytes;
}

/**
 * Post the XML request and return the inputStream. In general the Steam
 * will ge given to the XMLProcessor that will grab the pieces it needs
 */
+(NSData *) postViaHttpConnection:(NSData *)requestToSend{
	
	return [deCartaWebServices postViaHttpConnection:requestToSend readTimeout:DEFAULT_READ_TIMEOUT];
}

+(NSString *)getHost {
	return _host;
}

+(void)setHost:(NSString *)host{
	[_host release];
	_host=[host retain];
}
@end
