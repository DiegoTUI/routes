/*
 *  DCMapDelegate.h
 *  Sunder
 *
 *  Created by Daniel Posluns on 2/25/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <CoreLocation/CoreLocation.h>

@class DCMapView;

@protocol DCMapDelegate <NSObject>

@optional
- (void)loadComponents:(DCMapView *)mapView;
- (void)doneLoading:(DCMapView *)mapView;
- (void)dcMap:(DCMapView *)mapView viewChangedToLatLon:(CLLocationCoordinate2D)focusLatLon zoomLevel:(int)zoomLevel perspectiveAmount:(float)ratio yaw:(float)degrees;
- (void)dcMap:(DCMapView *)mapView zoomLevelChanged:(int)toZoomLevel canZoomIn:(BOOL)zoomIn canZoomOut:(BOOL)zoomOut;
- (void)dcMap:(DCMapView *)mapView tapAtLatLon:(CLLocationCoordinate2D)coord;
- (void)dcMap:(DCMapView *)mapView longPressAtLatLon:(CLLocationCoordinate2D)coord;

@end
