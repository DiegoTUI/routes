//
//  deCartaXMLProcessor.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deCartaConfig.h"
#import "deCartaPosition.h"
#import "deCartaTileGridResponse.h"
#import "deCartaFreeFormAddress.h"
#import "deCartaGeocodeResponse.h"
#import "deCartaStructuredAddress.h"
#import "deCartaPOISearchCriteria.h"
#import "deCartaPOI.h"
#import "deCartaRoutePreference.h"
#import "deCartaRoute.h"

#include <libxml/xmlreader.h>

// Given the restricted environment on a mobile device, we are just going to use strings
// to create XML. The other reason why this works is because the amount of information that
// changes between requests is very small.

/*!
 * @internal This class is used only inside API
 */
@interface deCartaXMLProcessor : NSObject
{
}

//@property (nonatomic, retain) deCartaConfig *config;

+ (NSString *) getHeader:(NSString *) methodName sessionId:(int)sessionId maxResponses:(int)maxResponses;

// Geocoding
+ (NSData *) geocodeRequest:(deCartaAddress *) address returnFreeFormAddress:(BOOL)returnFreeFormAddress;

/*!
 * @internal
 * @return NSArray of GeocodeResponses
 */
+ (NSArray *) processGeocode:(NSData *) xmlData returnFreeFormAddress:(BOOL)returnFreeFormAddress;

/*!
 * @internal
 * @return NSData containing the XML String to request a reverse geocode
 */
+ (NSData *) reverseGeocodeRequest:(deCartaPosition *) pos;

+ (deCartaStructuredAddress *) processReverseGeocode:(NSData *) xmlData ;

// POI
+ (NSData *) poiRequest:(deCartaPOISearchCriteria *) criteria;
+ (NSArray *) processPOI:(NSData *) xmlData;

// Route
+ (NSData *) routeRequest:(NSArray *) pos prefs:(deCartaRoutePreference *) prefs;
+ (deCartaRoute *) processRoute:(NSData *) xmlData;

/*!
 * @internal
 * Creates a ROUK request which basically pings the server to see if it is alive
 * @return a byte arrary representing the entire xml request
 */
+ (NSData *) ruokRequest;

/*!
 * @internal
 * Handles an RUOK response, of which the only interesting information is the name
 * of the server we talked to
 */
+ (NSString *) processRUOK:(NSData *) xmlData;

@end
