//
//  DCNavigationManager.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/10/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class DCGuidanceConfig;
@class DCGuidanceUpdate;
@class DCNavigationConfig;
@class DCNavigationImpl;
@class DCNavigationUpdate;
@protocol DCNavigationDelegate;
@protocol DCGuidanceUpdate;

typedef void (^DCNavUpdateFn)(DCNavigationUpdate *);

@interface DCNavigationManager : NSObject
{
@private

@package
	DCNavigationImpl	*_dcnavImpl;
}

@property (nonatomic, readonly) DCNavigationConfig *navigationConfig;
@property (nonatomic, readonly) DCGuidanceConfig *guidanceConfig;
@property (nonatomic, readonly) id<DCGuidanceUpdate> lastGuidance;
@property (nonatomic, readonly) DCNavigationUpdate *lastUpdate;
@property (nonatomic, assign) BOOL audioMuted;

- (id)initWithConfig:(DCNavigationConfig *)config;

// Release the returned object to stop receiving updates
- (id)registerForNavigationUpdatesWithDelegate:(id<DCNavigationDelegate>)delegate;

- (void)configureGuidance:(DCGuidanceConfig *)config;
- (void)runGuidance;
- (void)cancelGuidance;
- (void)repeatManeuverAudio;

@end
