//
//  TUIRoute.h
//  routes
//
//  Created by Diego Lafuente on 12/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUISpot.h"

@interface TUIRoute : NSObject

/**
 * Creates an empty route
 * @return an empty TUIRoute
 */
+(TUIRoute *)emptyRoute;

/**
 * Creates an empty circular route
 * @return an empty circular TUIRoute
 */
+(TUIRoute *)emptyCircularRoute;

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
 * Resets the route.
 */
-(void)reset;

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
