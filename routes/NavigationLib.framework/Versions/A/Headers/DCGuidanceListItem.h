//
//  DCDirectionsListItem.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/21/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol DCGuidanceIcon;

@protocol DCGuidanceListItem <NSObject>

- (NSString *)description;
- (id<DCGuidanceIcon>)icon;
- (CLLocationCoordinate2D)coordinate;
- (float)incomingAngleDegrees;	// angle is clockwise from North = 0
- (float)outgoingAngleDegrees;	// angle is clockwise from North = 0
- (int)distance;
- (BOOL)isDestination;
- (BOOL)isEqual:(id<DCGuidanceListItem>)other;

@end
