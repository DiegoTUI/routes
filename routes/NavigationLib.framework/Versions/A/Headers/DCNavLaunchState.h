//
//  DCNavLaunchState.h
//  NavigationLib
//
//  Created by Daniel Posluns on 7/15/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface DCNavLaunchState : NSObject
{
	CLLocationCoordinate2D	vehiclePosition;
	CLLocationDirection		vehicleDirection;
	BOOL					beginActive;
	BOOL					beginNorthUp;
	BOOL					beginOverhead;
	BOOL					autoNightMode;
}

@property (nonatomic, readonly) CLLocationCoordinate2D vehiclePosition;
@property (nonatomic, readonly) CLLocationDirection vehicleDirection;
@property (nonatomic, assign) BOOL beginActive;
@property (nonatomic, assign) BOOL beginNorthUp;
@property (nonatomic, assign) BOOL beginOverhead;
@property (nonatomic, assign) BOOL autoNightMode;

- (id)init;
- (id)initWithVehiclePositon:(CLLocationCoordinate2D)position direction:(CLLocationDirection)direction;
- (void)setVehiclePosition:(CLLocationCoordinate2D)position direction:(CLLocationDirection)direction;

@end
