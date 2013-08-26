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
 * Returns the most reliable location of the user.
 * @return the user's location.
 */
-(void)getUserLocation;

/**
 * Sets user location
 */
-(void)setUserLocation:(CLLocation *)location;

/**
 * Adds a delegate to the delegate list
 */
-(void)addDelegate:(id<TUILocationManagerDelegate>)delegate;

@end

@protocol TUILocationManagerDelegate <NSObject>

-(void)locationReady:(CLLocation *) location;

@end
