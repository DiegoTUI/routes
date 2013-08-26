//
//  deCartaGeocoder.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaAddress.h"
#import "deCartaPosition.h"
#import "deCartaStructuredAddress.h"

/*!
 * @ingroup Geocode
 * @class deCartaGeocoder
 * The Geocoder object has two specific functions. It is used to perform 
 * geocoding, the translation of an address into a latitude and longitude 
 * coordinate, and to perform reverse geocoding (the translation of a latitude 
 * and longitude coordinate into an approximate address). While the deCartaMap
 * object can perform rudimentary geocoding in some of its methods, the Geocoder 
 * class can be used to more gracefully deal with the results of poor, or 
 * inexact, user input. Geocoder objects operate independently from deCartaMap objects, 
 * allowing web applications to utilize just geocoding or reverse geocoding 
 * functionality, should that be required.
 * @brief Translates addresses to geographic coordinates, and vice-versa.
 */
@interface deCartaGeocoder : NSObject {
	
}

/*!
 * Converts a geographic position (lat, lon) into an address.
 * Reverse geocodes are always approximated to the best possible address 
 * within the range of addresses available in the map data. Reverse 
 * geocoding is an asynchronous request made to the DDS Web Services, and 
 * thus requires a callBack function to catch the returned results.
 * @param position A pointer to a deCartaPosition object which contains
 * latitude & longitude geographic position information
 * @return A structured address corresponding with the specified position.
 */
+(deCartaStructuredAddress *)reverseGeocode:(deCartaPosition *)position;

/*!
 * Converts an address into a list of geographic positions.
 * Geocoding is an asynchronous request made to the DDS Web Services, and 
 * thus requires a callBack function to catch the returned results. 
 * @param address A pointer to a deCartaAddress object, which may be a 
 * deCartaStructuredAddress or a deCartaFreeFormAddress object.
 * @param returnFreeFormAddrss A boolean input. Set to TRUE to have the geocode
 * method return free-form addresses, or FALSE to return structured addresses.
 * This controls whether the deCartaAddress objects contained within the
 * returned deCartaGeocodeResponse array are deCartaStructuredAddress or 
 * deCartaFreeFormAddress objects.
 * @return An NSArray of deCartaGeocodeResponse objects, each of which contains
 * a geographic position (lat, lon)
 */
+(NSArray *)geocode:(deCartaAddress *)address returnFreeFormAddress:(BOOL)returnFreeFormAddrss;


@end
