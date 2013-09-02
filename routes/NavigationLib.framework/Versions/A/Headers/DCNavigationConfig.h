//
//  DCNavigationConfig.h
//  NavigationLib
//
//  Created by Daniel Posluns on 6/26/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <NavigationLib/DCConstants.h>

// Directories may be left nil to use their defaults:
//	configDir: Documents directory
//	resourceDir: Main bundle resource path
//	dataDir: Documents directory
//	applicationDir: Documents directory
//	logDir: Documents directory
//
// The server must always be specified. (Default port is 80.)

@interface DCNavigationConfig : NSObject
{
	NSString	*server;
	NSString	*configDir;
	NSString	*resourceDir;
	NSString	*dataDir;
	NSString	*logDir;
	NSString	*applicationDir;
	int			serverPort;
	DCLogLevel	fileLogLevel;
	DCLogLevel	consoleLogLevel;
}
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *configDir;
@property (nonatomic, retain) NSString *resourceDir;
@property (nonatomic, retain) NSString *dataDir;
@property (nonatomic, retain) NSString *applicationDir;
@property (nonatomic, retain) NSString *logDir;
@property (nonatomic, assign) int serverPort;
@property (nonatomic, assign) DCLogLevel fileLogLevel;
@property (nonatomic, assign) DCLogLevel consoleLogLevel;

- (id)initWithServer:(NSString *)aServer;
- (void)populateDefaults;

+ (DCNavigationConfig *)configWithServer:(NSString *)server;
+ (NSString *)defaultConfigDir;
+ (NSString *)defaultResourceDir;
+ (NSString *)defaultDataDir;
+ (NSString *)defaultApplicationDir;
+ (NSString *)defaultLogDir;
+ (int)defaultPort;
+ (DCLogLevel)defaultFileLogLevel;
+ (DCLogLevel)defaultConsoleLogLevel;

@end
