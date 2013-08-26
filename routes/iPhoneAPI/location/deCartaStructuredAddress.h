//
//  deCartaStructuredAddress.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deCartaAddress.h"

/*!
 * @ingroup Location
 * @class deCartaStructuredAddress
 * A structured address is an address broken into its logical parts
 * @brief An address represented by its logical parts.
 */

@interface deCartaStructuredAddress : deCartaAddress
{
	NSString *_buildingNumber;
	NSString *_street;
	NSString *_countrySubdivision;
	NSString *_countrySecondarySubdivision;
	NSString *_municipality;
	NSString *_postalCode;
	NSString *_municipalitySubdivision;
	NSString *_postedSpeedLimit;
}

/*! Address number for this location. */
@property(nonatomic, retain) NSString *buildingNumber;

/*! Name and designation of the street (ie Main St) for this location. */
@property(nonatomic, retain) NSString *street;

/*! Sub-country administrative division (ie the state, province, or region) for this location. */
@property(nonatomic, retain) NSString *countrySubdivision;

/*! County (or equivalent) for this location. */
@property(nonatomic, retain) NSString *countrySecondarySubdivision;

/*! City, town, village, or equivalent for this location. */
@property(nonatomic, retain) NSString *municipality;

/*! Postal code, postcode, ZIP code, or equivalent numerical code for this location. */
@property(nonatomic, retain) NSString *postalCode;

/*! Recognized neighborhood, borough, or equivalent for this location. */
@property(nonatomic, retain) NSString *municipalitySubdivision;

/*! The posted speed limit for the road segment at this address. */	
@property(nonatomic, retain) NSString *postedSpeedLimit;

/*! Indicates whether the structured address is complete. */
-(BOOL)isCompleteAddress;

/*! Returns the structured address as a free-form address string.
 * Example: 4 N 2nd St, San Jose, CA 95113
 * @param delim A delimeter to insert between the street address and
 * municipality (a comma in the example)
 * @return String with free-form address
 */
-(NSString *)formatAddress:(NSString *)delim;

/*! Returns the structured address as a free-form address string.
 * Example: 4 N 2nd St, San Jose, CA 95113
 * @param lineDelim A delimeter to insert between the street address and
 * municipality (a comma in the example)
 * @param fldDelim inserted between city and state and postal code
 * @return String with free-form address
 */
-(NSString *)formatAddressWithLineDelim:(NSString *)lineDelim fldDelim:(NSString *)fldDelim ;

/*! Initializes a deCartaStructuredAddress object
 * @return Objective-C ID of the returned deCartaStructuredAddress object.
 */
-(id)init;

@end
