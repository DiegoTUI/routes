//
//  DCMapServerConfig.h
//  NavigationLib
//
//  Created by Daniel Posluns on 4/29/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum DCMapServerStyleType
{
	DCMAP_SERVER_STYLE_RASTER_TILE,
	DCMAP_SERVER_STYLE_VECTOR_TILE,
	DCMAP_SERVER_STYLE_WS_REQUEST,
	DCMAP_SERVER_STYLE_BULK_RASTER,
	DCMAP_SERVER_STYLE_BULK_VECTOR,
	DCMAP_SERVER_STYLE_PREFETCH,
	
	DCMAP_SERVER_STYLE_COUNT
}
DCMapServerStyleType;

@interface DCMapServerConfig : NSObject
{
	NSString	*server;
	NSString	*style;
	NSString	*user;
	NSString	*password;
	NSString	*styleOverrides[DCMAP_SERVER_STYLE_COUNT];
}
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *style;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;

- (id)init;
- (id)initWithServer:(NSString *)server style:(NSString *)style user:(NSString *)user password:(NSString *)password;
- (void)setStyle:(DCMapServerStyleType)styleType toOverride:(NSString *)overrideType;

@end
