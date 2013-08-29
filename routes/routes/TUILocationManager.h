//
//  TUILocationManager.h
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol TUILocationManagerDelegate;

@interface TUILocationManager : NSObject

/**
 * Returns a unique instance of the Context Cache.
 * @return a singleton.
 */
+(TUILocationManager *)sharedInstance;


/**
 * Returns the most reliable location for the user.
 * @return the user's location.
 */
-(void)getUserLocation;

/**
 * Return home location.
 * @return the location of home.
 */
-(deCartaPosition *)getHomeLocation;

/**
 * Stores Map Center
 */
-(void)storeMapCenter:(CLLocation *)location;

/**
 * Stores zoom level of the map
 */
-(void)storeZoomLevel:(float)zoomLevel;

/**
 * Gets the last zoom level of the map.
 * @return the current zoom level
 */
-(float)getZoomLevel;

/**
 * Adds a delegate to the delegate list
 */
-(void)addDelegate:(id<TUILocationManagerDelegate>)delegate;

@end

@protocol TUILocationManagerDelegate <NSObject>

-(void)userLocationReady:(CLLocation *) location;

@end
