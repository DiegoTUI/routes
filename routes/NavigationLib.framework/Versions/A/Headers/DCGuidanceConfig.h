//
//  DCGuidanceConfig.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/16/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

#import "DCGuidanceConstants.h"

@interface DCGuidanceConfig : NSObject
{
	CLLocationCoordinate2D	destination;
	CLLocationCoordinate2D	origin;
	DCGuidanceUnits			units;
	DCGuidanceRouteMode		routeMode;
	DCGuidanceHybridMode	routeHybridMode;
	DCGuidanceHybridMode	ttsHybridMode;
	NSString				*sensorLogPath;
	int						routeOptionMask;
	BOOL					simulate;
	int						simulationSpeed;
}

@property (nonatomic, assign) CLLocationCoordinate2D destination;
@property (nonatomic, assign) CLLocationCoordinate2D origin;
@property (nonatomic, assign) DCGuidanceUnits units;
@property (nonatomic, assign) DCGuidanceRouteMode routeMode;
@property (nonatomic, assign) DCGuidanceHybridMode routeHybridMode;
@property (nonatomic, assign) DCGuidanceHybridMode ttsHybridMode;
@property (nonatomic, retain) NSString *sensorLogPath;
@property (nonatomic, assign) int routeOptionMask;
@property (nonatomic, assign) BOOL simulate;
@property (nonatomic, assign) int simulationSpeed;

// Destination coordinate is required.
// Origin coordinate is required if simulate == YES. It is optional for GPS or sensorlog playback.
//
// Best practice is to only supply an origin coordinate if it is of maximum accuracy (i.e. from GPS) in order to
// minimize the likelihood of immediate rerouting.
- (id)initWithDestination:(CLLocationCoordinate2D)aDestination;
- (id)initWithDestination:(CLLocationCoordinate2D)aDestination origin:(CLLocationCoordinate2D)anOrigin;

- (void)setRouteOption:(DCGuidanceRouteOption)option;
- (void)clearRouteOption:(DCGuidanceRouteOption)option;
- (void)clearAllRouteOptions;
- (BOOL)isRouteOptionSet:(DCGuidanceRouteOption)option;

+ (DCGuidanceConfig *)configWithDestination:(CLLocationCoordinate2D)aDestination;
+ (DCGuidanceConfig *)configWithDestination:(CLLocationCoordinate2D)aDestination origin:(CLLocationCoordinate2D)anOrigin;

@end
