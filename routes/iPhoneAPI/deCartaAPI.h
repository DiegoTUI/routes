/*
 *  deCartaAPI.h
 *  iPhoneRefApp
 *
 *  Created by Z.S. on 3/25/11.
 *  Copyright 2011 deCarta, Inc. All rights reserved.
 *
 */

/*! @defgroup RefApp deCarta iPhone API Reference Application Classes */
/*! @defgroup Route Route Calculations */
/*! @defgroup POI Point-of-interest query classes */
/*! @defgroup Map Classes for map display and map-related functionality */
/*! @defgroup Location Position and Location Classes */
/*! @defgroup Geocode Geocode and Reverse Geocode Operations */
/*! @defgroup Event API Event Handling */
/*! @defgroup Global Global API data types, variables, and objects */
/*! @defgroup Util Utility Classes */



/*!
 * @mainpage iPhone API
 * <center>
 * <img src="logo.png"/>
 * </center>
 *
 * <p>
 * The deCarta iPhone API provides a framework for rapid development of
 * location-based iPhone applications. This framework uses Objective-C to
 * provide modular fluid maps, panning, zooming, geocoding, reverse geocoding,
 * point-of-interest searching, route calculation and pin overlays.
 * </p>
 * <p>
 * The deCarta iPhone API utilizes the deCarta DDS Web Services to perform much
 * of its underlying functionality, so many of the iPhone API methods will
 * perform client-server communications to perform the underlying
 * functionality.
 * </p>
 * <p>
 * The following sections describe high-level features of the deCarta iPhone
 * API, and provides some guidance as to the classes of the API that are used
 * for performing key functions.
 * </p>
 * <br>
 * <br>
 * <h2>Authentication</h2>
 * <p>
 * The deCarta iPhone API requires authentication with the clientName and
 * clientPassword you received when registering on the deCarta Developer Zone 
 * (developer.decarta.com). These are distinct from the email address and 
 * password that you use to login to the deCarta Developer Zone.
 * </p>
 * <p>
 * The deCarta iPhone API provides a global structure called g_config, 
 * which is an instance of a deCartaConfigStruct structure. Valid credentials
 * must be set in the properties of the g_config structure for API calls which
 * require deCarta DDS Web Services to function.</p>
 * <p>Example:</p>
 * <p><pre class="prettyprint">
 * //Set the configuration settings for the application using the
 * globally-defined g_config structure:
 * g_config.clientName=@"";
 * g_config.clientPassword=@"";
 * g_config.configuration_default=@"global-decarta";
 * g_config.configuration_high_res=@"global-decarta-hi-res";
 * g_config.transparentConfiguration=@"global-mobile-transparent";
 * g_config.host=@"http://ws.decarta.com/openls/openls";
 *
 * //Configure additional API settings (see deCartaConfig.h for all options):
 * g_config.LOG_LEVEL = LOG_LEVEL_DEBUG; //Sets logging level to "DEBUG". See enumerated type in deCartaLogger.h
 * g_config.ENABLE_TILT = TRUE;
 * g_config.ENABLE_ROTATE = TRUE;
 * g_config.COMPASS_PLACE_LOCATION = 1;
 * </pre>
 * </p>
 * <br>
 * <br>
 * <h2>Map Display</h2>
 * <p>
 * The core of the deCarta iPhone API is the deCartaMapView class.
 * This class provides methods for displaying and manipulating the map.
 * </p>
 * <p>
 * For an example of how to set up the map display, see the
 * MapViewController in the sample application.
 * </p>
 * <h3>Centering</h3>
 * <p>To center the map on a specified position, use the 
 * deCartaMapView.centerOnPosition: method.</p>
 * <h3>Zooming</h3>
 * <p>To zoom the map in or out one level, use
 * deCartaMapView.zoomIn or deCartaMapView.zoomOut, or use
 * deCartaMapView.zoomTo: to skip directly to a new zoom level.</p>
 * <br>
 * <br>
 * <h2>Find Address/Geocode (find a geographic position from an address)</h2>
 * <p>To find the geographic position of an address, first store the
 * free-form address as a deCartaFreeFormAddress, then use that address
 * with the deCartaGeocoder.geocode:returnFreeFormAddress: method to determine the geocoded location.
 * </p>
 * <p>
 * Free-form addresses permit flexible and forgiving user-input,
 * which allows for incomplete or partial addresses, errors, and
 * misspellings. The geocoder contacts the deCarta DDS Web Server to
 * determine the best available matches for the free-form address.
 * </p>
 * <p>
 * When the response from the server is received, it will contain an
 * array of deCartaGeocodeResponse objects, each which contain a
 * deCartaStructuredAddress or deCartaFreeFormAddress (depending on what is
 * requested when calling the geocode method), 
 * and a corresponding deCartaPosition indicating the geographic lat/lon
 * position of that address. The application can then provide the user
 * the option to select the best matching address from a list,
 * in order to determine the desired position.
 * </p>
 * <p>
 * See the GeocodeViewController class in the sample application for
 * an example.
 * </p>
 * <br>
 * <br>
 * <h2>Reverse Geocode (find an address from a geographic position)</h2>
 * <p>To find the street address associated with a geographic position,
 * first store the geographic position as a deCartaPosition object,
 * then use that deCartaPosition with the deCartaGeocoder.reverseGeocode:
 * method to determine the reverse geocoded location.
 * </p>
 * <p>
 * The geocoder contacts the deCarta DDS Web Server to determine the
 * reverse geocoded position. When the response from the server is
 * received, it will contain a deCartaStructuredAddress object with the
 * corresponding street address that best matches the position (it is an
 * approximate, interpolated address). It will throw an exception if an
 * appropriate address can not be determined.
 * </p>
 * <p>
 * See the MapViewController.doReverseGeocoding: method in the
 * MapViewController class of the sample application for an example.
 * </p>
 * <br>
 * <br>
 * <h2>Point of Interest Search</h2>
 * <p>
 * To search for a point of interest, first determine the
 * center-location of the area to search (as a deCartaPosition), using
 * the current location or using a geocoded address. Then, populate a
 * deCartaPOISearchCriteria object with the search criteria for the
 * point of interest search. Then use a deCartaPOIQuery object to
 * perform the point of interest query using the criteria.
 * </p>
 * <p>
 * The deCartaPOIQuery contacts the deCarta DDS Web Server to find a
 * list of best matches for the search criteria which are returned as
 * an array of deCartaPOI objects.
 * </p>
 * <p>
 * See the POIViewController class in the sample application for an 
 * example.
 * </p>
 * <br>
 * <br>
 * <h2>Calculate a Route</h2>
 * <p>
 * Routing is crucial to all location-based services applications,
 * both to visually display a route on a map and to provide
 * turn-by-turn route instructions. The routing functionaliy is
 * performed by the deCartaRouteQuery class.
 * </p>
 * <p>
 * When calculating a route, the deCartaRouteQuery.query:routePreference:
 * method requires an origin deCartaPosition, a destination deCartaPosition,
 * and a deCartaRoutePreference object that has been configured with
 * desired route query settings.
 * </p>
 * <p>
 * For route visualization, the deCartaRoutePreference.returnGeometry
 * property should be set to YES. In this case, the returned
 * deCartaRoute object will contain an array of deCartaPosition objects.
 * These positions can then be used with the deCartaShape API for
 * drawing a series of lines onto the map.
 * </p>
 * <p>
 * For turn-by-turn route instructions, the
 * deCartaRoutePreference.returnInstructions property should be set to
 * YES. In this case, the returned deCartaRoute object will
 * contain an array of deCartaRouteInstruction objects, which provide the 
 * instructions at each maneuver.
 * </p>
 * <p>
 * See the RouteViewController class in the sample application for an
 * example.
 * </p>
 */ 


#ifndef DECARTAAPI_H
#define DECARTAAPI_H

#import "deCartaConfig.h"
#import "deCartaGlobals.h"

#import "deCartaEventListener.h"
#import "deCartaEventSource.h"

#import "deCartaGeocoder.h"
#import "deCartaGeocodeResponse.h"

#import "deCartaAddress.h"
#import "deCartaBoundingBox.h"
#import "deCartaFreeFormAddress.h"
#import "deCartaLocale.h"
#import "deCartaPosition.h"
#import "deCartaStructuredAddress.h"

#import "deCartaCircle.h"
#import "deCartaCompass.h"
#import "deCartaIcon.h"
#import "deCartaInfoWindow.h"
#import "deCartaLength.h"
#import "deCartaMapView.h"
#import "deCartaOverlay.h"
#import "deCartaPin.h"
#import "deCartaPolyline.h"
#import "deCartaRotationTilt.h"
#import "deCartaShape.h"
#import "deCartaPolygon.h"

#import "deCartaPOI.h"
#import "deCartaPOIQuery.h"
#import "deCartaPOISearchCriteria.h"

#import "deCartaRoute.h"
#import "deCartaRouteAddress.h"
#import "deCartaRouteInstruction.h"
#import "deCartaRoutePreference.h"
#import "deCartaRouteQuery.h"

#import "deCartaLogger.h"
#import "deCartaUtil.h"
#import "deCartaXYDouble.h"
#import "deCartaXYFloat.h"
#import "deCartaXYInteger.h"
#import "deCartaXYZ.h"



#endif
