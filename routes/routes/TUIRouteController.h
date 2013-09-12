//
//  TUIRouteController.h
//  routes
//
//  Created by Diego Lafuente on 12/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIRoute.h"

@interface TUIRouteController : NSObject

/**
 * Returns a unique instance of the Route Controller.
 * @return a singleton.
 */
+(TUIRouteController *)sharedInstance;
/**
 * Returns the initial spot of the route.
 * @return a TUISpot.
 */
-(TUISpot *)startSpot;

/**
 * Returns the final spot of the route.
 * @return a TUISpot.
 */
-(TUISpot *)endSpot;

/**
 * Returns the next spot in the route.
 * If shouldMove is YES, then _currentPoint advances 1 spot
 * @return a TUISpot. Nil if there is no next point.
 */
-(TUISpot *)nextSpot:(BOOL)shouldMove;

/**
 * Resets the route. Brings the cursor to the first point of the route
 */
-(void)reset;

/**
 * Flushes the route. Empties the route.
 */
-(void)flush;

/**
 * Adds a new spot to the route.
 */
-(void)addSpot:(TUISpot *)spot;

/**
 * Removes a spot from the route.
 */
-(void)removeSpot:(TUISpot *)spot;

/**
 * Returns the spot for certain indexpath
 * @return a TUISpot. Nil if not found
 */
-(TUISpot *)spotForIndexPath:(NSIndexPath *)indexPath;


@end
