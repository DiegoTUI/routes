//
//  DCMapLaunchState.h
//  NavigationLib
//
//  Created by Daniel Posluns on 4/29/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class DCMapServerConfig;

@interface DCMapLaunchState : NSObject
{
	DCMapServerConfig		*tileConfig;
	DCMapServerConfig		*wsConfig;
	NSString				*mapProperties;
	NSString				*configProperties;
	NSString				*loggingProperties;
	CLLocationCoordinate2D	startCoordinate;
	float					startPerspectiveRatio;
	float					startYawDegrees;
	int						startZoomLevel;
}

@property (nonatomic, retain) DCMapServerConfig *tileConfig;
@property (nonatomic, retain) DCMapServerConfig *wsConfig;
@property (nonatomic, retain) NSString *mapProperties;
@property (nonatomic, retain) NSString *configProperties;
@property (nonatomic, retain) NSString *loggingProperties;
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign) float startPerspectiveRatio;
@property (nonatomic, assign) float startYawDegrees;
@property (nonatomic, assign) int startZoomLevel;

- (id)init;
- (id)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude zoom:(int)zoom;
- (id)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude zoom:(int)zoom perspectiveRatio:(float)perspectiveRatio yawDegrees:(float)yawDegrees;

@end
