//
//  DCNavigationDelegate.h
//  NavigationLib
//
//  Created by Daniel Posluns on 6/27/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCNavigationManager;
@class DCNavigationUpdate;

@protocol DCNavigationDelegate <NSObject>

@optional
- (void)navigationManager:(DCNavigationManager *)manager update:(DCNavigationUpdate *)update;
- (void)navigationManagerSetupFailed:(DCNavigationManager *)manager;
- (void)navigationManagerRouteFailed:(DCNavigationManager *)manager;
- (void)navigationManagerDestinationReached:(DCNavigationManager *)manager;
- (void)navigationManager:(DCNavigationManager *)manager rerouteWithRecommendedAbort:(BOOL)recommendAbort;
- (void)navigationManagerWaitingForGPS:(DCNavigationManager *)manager;
- (void)navigationManagerDoneWaitingForGPS:(DCNavigationManager *)manager;
- (void)navigationManagerGPSDenied:(DCNavigationManager *)manager;

@end
