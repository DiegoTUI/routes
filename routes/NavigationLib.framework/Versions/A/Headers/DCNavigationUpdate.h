//
//  DCNavigationUpdate.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/16/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@protocol DCGuidanceAnnouncement;
@protocol DCGuidanceUpdate;

@interface DCNavigationUpdate : NSObject
{
	id<DCGuidanceUpdate>		guidance;
	id<DCGuidanceAnnouncement>	announcement;
	CLLocationCoordinate2D		vehiclePosition;
	CLLocationDegrees			vehicleDirection;
	BOOL						destinationReached;
}

@property (nonatomic, retain) id<DCGuidanceUpdate> guidance;
@property (nonatomic, retain) id<DCGuidanceAnnouncement> announcement;
@property (nonatomic, assign) CLLocationCoordinate2D vehiclePosition;
@property (nonatomic, assign) CLLocationDegrees vehicleDirection;
@property (nonatomic, assign) BOOL destinationReached;

@end
