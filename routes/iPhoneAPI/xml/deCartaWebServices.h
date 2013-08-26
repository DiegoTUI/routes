//
//  deCartaWebServices.h
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaTile.h"

/*!
 * @internal
 * This class is only used inside API
 */
@interface deCartaWebServices : NSObject {

}
+(NSString *) setHostViaRUOK:(NSString *) generalHost;
+(NSData *)getTileImage:(deCartaTile *)requestTile;
+(NSData *) postViaHttpConnection:(NSData *)requestToSend readTimeout:(int)readTimeout;
+(NSData *) postViaHttpConnection:(NSData *)requestToSend;
+(NSString *)getHost;
+(void)setHost:(NSString *)host;
@end
