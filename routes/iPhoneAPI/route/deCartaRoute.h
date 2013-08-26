//
//  deCartaRoute.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaBoundingBox.h"
#import "deCartaLength.h"

/*!
 * @ingroup Route
 * @class deCartaRoute
 * The deCartaRoute class is used to encapsulate all information needed to describe a
 * route calculated by the deCarta DDS Web Services.
 * @brief A navigable route from one map location to another, with route meta-data.
 */
@interface deCartaRoute : NSObject {
	deCartaBoundingBox * _boundingBox;
	NSString * _totalTime;
	deCartaLength * _totalDistance;
	NSString * _viaPointSequence;
	NSMutableArray * _routeInstructions;
	NSMutableArray * _routeGeometry;
	NSString * _routeId;
}
/*! Bounding box around the geometry of the route */
@property(nonatomic,retain) deCartaBoundingBox * boundingBox;

/*! 
 * A text summary of the estimated travel time of the entire route. Example, 
 * "Total Time: 2 minutes 31 seconds"
 */
@property(nonatomic,retain) NSString * totalTime;

/*!
 * A text summary of the total surface distance traveled along the entire route.
 * (Units of measure are defined within the deCartaLength class)
 */
@property(nonatomic,retain) deCartaLength * totalDistance;

/*!
 * A comma delimited string used to identify the order in which the waypoints are 
 * visited in an optimized route. When a multipoint route is optimized the order of the 
 * waypoints can be different than the way you entered them. The waypoints are 
 * referred in zero-based array order (e.g. '0' is actually the first waypoint). 
 * Example, "1,0" means the second waypoint was visited first, followed by the first 
 * waypoint.
 * Note: the origin and destination are not considered waypoints, and are not referred 
 * to by this field. Only the points between the origin and destination count as waypoints.
 */
@property(nonatomic,retain) NSString * viaPointSequence;

/*!
 * Array of deCartaRouteInstruction instances. Each RouteInstruction describes one specific maneuver along the route.
 */
@property(nonatomic,retain) NSMutableArray * routeInstructions;

/*!
 * Array of deCartaPosition objects that fully describe the geometry of the route.
 * Note: geometry is only returned when the route request is made through a 
 * deCartaRouteQuery request. Long routes can produces tens of thousands of 
 * deCartaPosition objects.
 */
@property(nonatomic,retain) NSMutableArray * routeGeometry;

/*! A unique string for identifying this route by name. */
@property(nonatomic,retain) NSString * routeId;

/*!
 * Provides a route summary providing route distance and travel time.
 * @return String with route summary.
 */
-(NSString *)getSummary;

@end
