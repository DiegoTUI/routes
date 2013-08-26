//
//  deCartaRouteQuery.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaPosition.h"
#import "deCartaRoutePreference.h"
#import "deCartaRoute.h"

/*!
 * @ingroup Route
 * @class deCartaRouteQuery
 * This class provides a method for querying the deCarta DDS Web Service and retrieve
 * a route, including the geometry that defines the path of the route. This can be used
 * in conjunction with the client-side deCartaShape rendering API to overlay a custom-defined 
 * route dynamically (e.g. without a refresh) on a deCartaMap. Using a deCartaRoutePreferences
 * object you can configure the deCartaRouteQuery to return the route instructions and/or
 * route geometry.<br><br>
 * @brief Class for performing a deCarta DDS Web Service query to calculate a route to a destination.
 */
@interface deCartaRouteQuery : NSObject {

}

/*!
 * Compute a route and return the detailed information within an instance of the deCartaRoute class.
 * @param positions An array of deCartaPosition objects that determine the stops along the route to
 * be calculated. The first position is the origin, the last position is the destination,
 * and each position in between is a waypoint.
 * @param routePreference An object containing rules for the route calculation.
 * @return A deCartaRoute object that describes the route, or null if there was an error 
 * determining the route.
 */
+(deCartaRoute *)query:(NSArray *)positions routePreference:(deCartaRoutePreference *)routePreference;

@end
