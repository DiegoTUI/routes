//
//  DCGuidanceUpdate.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/16/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCGuidanceIcon;

@protocol DCGuidanceUpdate <NSObject>

- (NSString *)currentStreet;
- (NSString *)nextStreet;
- (id<DCGuidanceIcon>)maneuverIcon;
- (NSData *)routePoints;
- (NSArray *)directionsList;
- (int)distanceToCrossing;
- (int)distanceToDestination;
- (int)secondsToArrival;

@end
