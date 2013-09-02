//
//  DCNavViewController.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/7/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "DCMapViewController.h"

@class DCNavigationManager;
@class DCNavLaunchState;
@protocol DCGuidanceIcon;

@interface DCNavViewController : DCMapViewController
{
	DCNavigationManager		*navigationManager;
	DCNavLaunchState		*launchState;
	CLLocationCoordinate2D	vehiclePosition;
	CLLocationDirection		vehicleDirection;
	CLLocationCoordinate2D	destination;
	BOOL					navigationCameraActive;
	BOOL					autoNightMode;
}

@property (nonatomic, retain) DCNavigationManager *navigationManager;
@property (nonatomic, retain) DCNavLaunchState *launchState;
@property (nonatomic, assign) UIColor *routeMainColor;
@property (nonatomic, assign) UIColor *routeOutlineColor;
@property (nonatomic, readonly) CLLocationCoordinate2D vehiclePosition;
@property (nonatomic, readonly) CLLocationDirection vehicleDirection;
@property (nonatomic, readonly) CLLocationCoordinate2D destination;
@property (nonatomic, readonly) BOOL navigationCameraActive;
@property (nonatomic, readonly) BOOL autoNightMode;
@property (nonatomic, readonly) BOOL vehiclePositionValid;

+ (int)baseNavigationZoomLevel;

- (void)updateVehiclePosition:(CLLocationCoordinate2D)position direction:(CLLocationDirection)direction;
- (void)setNavigationCameraActive:(BOOL)active;
- (void)setAutoNightMode:(BOOL)enabled;
- (void)setDestination:(CLLocationCoordinate2D)destination;
- (void)clearDestination;
- (void)setRoutePoints:(NSData *)lonLatData completionHandler:(void (^)())handler;
- (void)setRoutePoints:(const CLLocationCoordinate2D *)points count:(size_t)count completionHandler:(void (^)())handler;
- (void)clearRoute;
- (void)highlightManeuver:(CLLocationCoordinate2D)location entryAngle:(float)degrees animated:(BOOL)animated;
- (void)displayRouteOverview;

// Maneuver icon generation
//
// May be configured with the following options:
//	- size: pixel dimensions of the icon (icons are square)
//	- colorImages: YES to generate full-color images if your icon components are full-color. Otherise NO for grayscale.
//		Prefer NO for improved performance.
//	- dualLayered: YES to generate two separate images for the inactive and active portions of the icon. NO to combine
//		the two images into a single image.
//	- inactiveColor: a color to use for drawing the inactive layer, ONLY IF dualLayered is NO.
//
// generateImagesForManeuverIcon: returns a NSArray with either 1 or 2 UIImage objects. If configured with dualLayered:
//		YES then it returns 2 UIImages of the inactive and active layer respectively, otherwise just 1 UIImage of the
//		composited layers.
- (void)configureManeuverIconsWithSize:(int)pixels colorImages:(BOOL)colorImages dualLayered:(BOOL)dualLayered inactiveColor:(UIColor *)inactiveColor;
- (NSArray *)generateImagesForManeuverIcon:(id<DCGuidanceIcon>)icon;
+ (UIColor *)maneuverIconDefaultInactiveColor;

// Subclasses may override these to implement custom behaviors
- (void)navigationCameraBecameActive:(BOOL)active;

@end
