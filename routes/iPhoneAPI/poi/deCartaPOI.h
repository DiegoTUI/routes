//
//  deCartaPOI.h
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaAddress.h"
#import "deCartaPosition.h"
#import "deCartaLength.h"

/*!
 * @ingroup POI
 * @class deCartaPOI
 * Points of Interest, or POIs, are locations on a map that have some meaning 
 * to the user. They could be restaurants, sales prospects, parking meters, 
 * really anything that is of interest. POIs are always located at a specific 
 * latitude and longitude coordinate, or deCartaPosition, and will have 
 * specific information associated with them.
 * The deCartaPOIQuery class is used to query the DDS Web Services to retrieve
 * relevant points of interest, which are returned in the form of deCartaPOI
 * objects.
 * Should an application have access to proprietary data that is to be displayed 
 * on a deCartaMap, the POI object is not necessarily needed; one can simply 
 * display the proprietary data within a deCartaPin overlaid on the deCartaMap.
 * @brief The location and details of a point-of-interest object.
 */
@interface deCartaPOI : NSObject {
	NSString * _name;
	NSString * _phoneNumber;
	deCartaAddress * _address;
	deCartaPosition * _position;
	deCartaLength * _distance;
    
    /*! corridor search distance from route origin to exit for POI */
    deCartaLength *_distanceOnRoute;
    /*! corridor search distance from route exit to POI */
    deCartaLength *_distanceOffRoute;
    /*! corridor search time in seconds from route origin to exit for POI */
    int _durationOnRoute;
    /*! corridor search time in seconds from route exit to POI */
    int _durationOffRoute;
    
	
}
/*! The name of the POI */
@property(nonatomic,retain)NSString * name;

/*! The phone number of the POI */
@property(nonatomic,retain)NSString * phoneNumber;

/*! The street address of the POI */
@property(nonatomic,retain)deCartaAddress * address;

/*! The geographic (lat, lon) position of the POI */
@property(nonatomic,retain)deCartaPosition * position;

/*! Distance from the center of your search area to the POI.
 * (Units of measure are defined within the deCartaLength class)
 */
@property(nonatomic,retain)deCartaLength * distance;

@property(nonatomic, retain) deCartaLength * distanceOnRoute;
@property(nonatomic, retain) deCartaLength * distanceOffRoute;
@property(nonatomic, assign) int durationOnRoute;
@property(nonatomic, assign) int durationOffRoute;

@end
