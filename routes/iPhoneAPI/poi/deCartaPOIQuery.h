//
//  deCartaPOIQuery.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaPOISearchCriteria.h"

/*!
 * @ingroup POI
 * @class deCartaPOIQuery
 * The deCartaPOIQuery contacts the deCarta DDS Web Server to look up points of 
 * interest that meet the specified search criteria. The query returns an
 * array of deCartaPOI objects which contain location and descriptive information
 * about each of the returns points of interest.
 * @brief Class for performing point-of-interest searches
 */
@interface deCartaPOIQuery : NSObject {

}
/*! Performs a query using the deCarta DDS Web Server.
 * @param criteria The search string and search area for locating points of interest in a specified region.
 * @return An array of deCartaPOI objects with locations and descriptions of each found point of interest.
 */
+(NSArray *)query:(deCartaPOISearchCriteria *)criteria;

@end
