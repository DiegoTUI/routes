//
//  deCartaPosition.h
//  deCartaLibrary
//
//  Created by S.G. on 10/3/08.
//  Copyright 2008-09 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @ingroup Location
 * @class deCartaPosition
 * Decimal latitude and longitude coordinates for a specific location. This is an 
 * immutable position object.
 * @brief Decimal latitude and longitude coordinates for a specific location.
 */
@interface deCartaPosition : NSObject <NSCopying>
{
	double _lat;
	double _lon;
}
/*! Latitude (decimal) */
@property(nonatomic,assign,readonly)double lat;

/*! Longitude (decimal) */
@property(nonatomic,assign,readonly)double lon;

/*!
 * Initializes the deCartaPosition object with a latitude and longitude.
 * @param inLat Decimal latitude
 * @param inLon Decimal longitude
 * @return deCartaPosition object
 */
- (id) initWithLat:(double) inLat andLon:(double) inLon;

/*!
 * Initializes the deCartaPosition object with a string that represents the latitude and longitude.
 * @param latlon NSString object representing the latitude and longitude
 * @return deCartaPosition object
 */
- (id) initWithString:(NSString *) latlon;

/*!
 * Creates and returns a deCartaPosition object with a specified latitude and longitude
 * @param inLat Latitude (double)
 * @param inLon Longitude (double)
 * @return deCartaPosition object for the specified location
 */
+(deCartaPosition *) positionWithLat:(double)inLat andLon:(double)inLon;

/*!
 * Creates and returns a deCartaPosition object with a specified location,
 * specified by a string. The string is comprised of a latitude value and
 * a longitude value, separated by either a space or a comma.
 * @param latlon string input of the format "lat lon" or "lat,lon"
 * @return deCartaPosition object for the specified location
 */
+(deCartaPosition *) positionWithString:(NSString *)latlon;


@end
