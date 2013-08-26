//
//  deCartaGeocodeResponse.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaAddress.h"
#import "deCartaPosition.h"

/*!
 * @ingroup Geocode
 * @class deCartaGeocodeResponse
 * When using the deCartaGeocoder class's geocode: method to perform an address search on
 * a free-form address, an array of deCartaGeocodeResponse objects are returned, which
 * encapsulate the list of results. Each deCartaGeocodeResponse object contains
 * a structured address and position for the result, along with _matchType and _accuracy
 * information about that match.
 * @brief Object returned by a deCartaGeocoder::geocode: query.
 */
@interface deCartaGeocodeResponse : NSObject {
    /*! The structured address associated with this match result. This may
     * be either a deCartaStructuredAddress or a deCartaFreeFormAddress.
     */
	deCartaAddress * _address;

    /*! The geographic position (lat, lon) associated with this match result. */	
	deCartaPosition * _position;

    /*!
     * Description of the geocoding method used to create this match. This 
     * can be used to determine how reliable the results are.
     */
	NSString * _matchType;
    /*!
     * A percentage between 0-1 representing the accuracy of the pattern match for this
     * geocoding operation, where 0 is bad and 1 is as good as it gets. 
     */
	double _accuracy;
}
/*! The structured address associated with this match result. This may
 * be either a deCartaStructuredAddress or a deCartaFreeFormAddress.
 */
@property(nonatomic,assign) double accuracy;

/*! The geographic position (lat, lon) associated with this match result. */	
@property(nonatomic,retain) NSString * matchType;

/*!
 * Description of the geocoding method used to create this match. This 
 * can be used to determine how reliable the results are.
 */
@property(nonatomic,retain) deCartaAddress * address;

/*!
 * A percentage between 0-1 representing the accuracy of the pattern match for this
 * geocoding operation, where 0 is bad and 1 is as good as it gets. 
 */
@property(nonatomic,retain) deCartaPosition * position;




@end
