//
//  deCartaPOISearchCriteria.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaPosition.h"

/*!
 * @ingroup POI
 * @class deCartaPOISearchCriteria
 * This class defines the search criteria (search area and search string) used by 
 * the deCartaPOIQuery.query: method to perform a point-of-interest search.
 * @brief Search criteria for the deCartaPOIQuery.query: method.
 */
@interface deCartaPOISearchCriteria : NSObject {
	deCartaPosition * _centerPosition;
	double _radius;
	NSString * _queryString;
	int _maximumResponses;
	NSString * _database;
	NSString * _rankCriteria;
	NSString * _sortCriteria;
	NSString * _sortDirection;
	NSString * _queryType;
	BOOL _allowAggregates;
	
	/*! corridor search routeId */
    NSString * _routeId;
	/*! corridor search duration in seconds, when corridorType="time" */
    int _duration;
	/*! corridor search type, can be distance, time or euclideanDistance */
    NSString * _corridorType;
	/*! corridor search distance in meters, when corridorType="distance" or "euclideanDistance */
    double _distance;
	NSString * _queryTypeAdj;
	NSString * _queryStringAdj;
}
/*! The geographic center (lat, lon) around which to search. */
@property(nonatomic,retain) deCartaPosition * centerPosition;

/*! The search radius, in meters. */
@property(nonatomic,assign) double radius;

/*! Free-form search string for point of interest search. */
@property(nonatomic,retain) NSString * queryString;

/*! Maximum number of responses to return from the query. */
@property(nonatomic,assign) int maximumResponses;

/*! 
 * Used for naming an external relational database (see deCarta DDS Web Services
 * docs for more details).
 */
@property(nonatomic,retain) NSString * database;

/*! The criteria for ranking POI query results.
 * Default: nil
 * Permitted values: "Score" or nil (see DDS documentation for additional options)
 */
@property(nonatomic,retain) NSString * rankCriteria;

/*! The criteria for sorting POI query results.
 * Default: nil
 * Permitted values: "Distance" or nil (see DDS documentation for additional options)
 */
@property(nonatomic,retain) NSString * sortCriteria;

/*! The direction for sorting POI query results.
 * Default: "Ascending"
 * Permitted values: "Ascending" or "Descending"
 */
@property(nonatomic,retain) NSString * sortDirection;

/*! The type of POI query, to control category or name-based searches
 * for POIs.
 * Permitted values: "Category" or "POIName"
 */
@property(nonatomic,retain) NSString * queryType;

/*! Not used. Set to FALSE. */
@property(nonatomic,assign) BOOL allowAggregates;

/*! Not used. */
@property(nonatomic,retain) NSString * routeId;

/*! Not used. */
@property(nonatomic,assign) int duration;

/*! Not used. */
@property(nonatomic,retain) NSString * corridorType;

/*! The search radius, in meters */
@property(nonatomic,assign) double distance;

/*! Not Used */
@property(nonatomic,retain) NSString * queryTypeAdj;

/*! Not Used */
@property(nonatomic,retain) NSString * queryStringAdj;



@end
