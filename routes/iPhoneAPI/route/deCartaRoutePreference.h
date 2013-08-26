//
//  deCartaRoutePreference.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaBoundingBox.h"

/*!
 * @ingroup Route
 * @class deCartaRoutePreference
 * The deCartaRoutePreference class holds a set of rules that define how a route 
 * should be calculated (when using the deCartaRouteQuery::query() method). There are specific 
 * types of routes, and each type of route follows a specific set of rules. For example, a 
 * Pedestrian style route will not traverse limited access roads (e.g. Freeways), but can go
 * down the wrong direction of a one-way street that is not prohibited to pedestrian traffic.
 * Providing users an opportunity to define their own routing style is important
 * for generating a route that is relevant to their needs.
 <p>The various different routing styles are summarized below.</p>
 <ul>
 <li>"AvoidFreeways" = Return a vehicular route that avoids limited access roads 
 (e.g. freeways) as much as possible.</li>
 <li>"Easy" = Return a vehicular route that attempts to make as few turns, balancing this constraint with the shortest travel time.</li>
 <li>"Fastest" = Return a vehicular route with the smallest, calculated travel time. This is the standard, and default routing style.</li>
 <li>"MoreFreeways" = Return a vehicular route that will attempt to use as many limited access roads (e.g. freeways) as possible.</li>
 <li>"NoFreeways" = Return a vehicular route that avoids limited access roads (e.g. freeways) entirely. This route will take only surface street and arterial roads to the destination.</li>
 <li>"Pedestrian" = Return a route fit for Pedestrian traffic. Routes will avoid limited access roads, ignore vehicular signage restrictions, obey impassible physical restrictions (like grade separations), take the most direct path possible, and utilize pedestrian only foot-traffic paths.</li>
 <li>"Shortest" = Return a vehicular route with the shortest total distance traveled.</li>
 </ul>
 * When a route has more than than three total points (i.e. more than an origin, one mid-point, and a destination), the route can be optimized. The waypoints, or mid-points between the origin and destination are re-calculated for optimal travel. The new optimized route follows the rules prescribed by the routing style. For example, a route prescribed to "AvoidFreeways" will still avoid freeways whether or not it is being optimized.
 * @brief Holds a set of rules that define how a route is calculated.
 */
@interface deCartaRoutePreference : NSObject {
	deCartaBoundingBox * _clippingBox;
	BOOL _returnInstructions;
	BOOL _returnGeometry;
	BOOL _returnRouteIdOnly;
	NSString * _style;
	NSString * _routeQueryType;
	NSString * _rules;
	BOOL _optimized;
	NSString * _expectedStartTime;
	BOOL _provideRouteHandle;
	NSString * _distanceType;
}
/*!
 * The bounding box containing the route, used for clipping the route geometry
 */
@property(nonatomic,retain)deCartaBoundingBox * clippingBox;

/*!
 * Boolean configuration for whether the route request should return
 * route instructions (turn by turn) for the route
 */
@property(nonatomic,assign)BOOL returnInstructions;

/*!
 * Boolean configuration for whether the route request should return route geometry 
 * (Vector of Positions for rendering route on map)
 */
@property(nonatomic,assign)BOOL returnGeometry;

/*! Defines whether the a route query returns only a route ID.
 * Generally this should be FALSE to return full route information.
 */
@property(nonatomic,assign)BOOL returnRouteIdOnly;

/*!
 * The style of route to calculate, valid settings are, "Fastest", "Shortest", 
 * "Pedestrian", "AvoidFreeways", "NoFreeways", "MoreFreeways", or "Easy".
 */
@property(nonatomic,retain)NSString * style;

/*!
 * Tells the deCarta DDS Web Service which basic routing style to use, valid settings are 
 * "RMAN" or (default) "RTXT". It is recommended to not change this setting unless you 
 * have been instructed to do so.
 */
@property(nonatomic,retain)NSString * routeQueryType;

/*!
 * Optional parameter for overriding default maneuver rules file used on server.
 */
@property(nonatomic,retain)NSString * rules;

/*!
 * Defines whether the waypoints between the origin and destination should be traversed 
 * in an optimal order. 'true' means optimize the order, 'false' means traverse the path 
 * through the waypoints in the original order described.
 */
@property(nonatomic,assign)BOOL optimized;

/*!
 * For use with predictive traffic, if applicable
 */
@property(nonatomic,retain)NSString * expectedStartTime;

/*! Indicates whether the route query should return a route handle (route id).
 * Normally should be set to TRUE.
 */
@property(nonatomic,assign)BOOL provideRouteHandle;

/*! Sets the units of measure for route queries.
 * "MI" for mile, "KM" for kilometers, "M" for meters
 */
@property(nonatomic,retain)NSString * distanceType;



@end
