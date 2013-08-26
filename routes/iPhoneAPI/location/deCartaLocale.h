//
//  deCartaLocale.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>


/*!
 * @ingroup Location
 * @class deCartaLocale
 * A deCartaLocale object represents a specific geographical, political, or 
 * cultural region. An operation that requires a deCartaLocale to perform 
 * its task is called locale-sensitive and uses the deCartaLocale to tailor 
 * information for the user. Currently, deCartaLocale can be attached to a 
 * deCartaFreeFormAddress object to aid in producing better results when 
 * calling deCartaGeocoder.geocode:.
 <p>The current valid pairs of language and country codes are as follows:</p>
 <ul>
 <li>Language Code: "DE"; Country Code: "AT"</li>
 <ul><li>for German in Austria</li></ul>
 <li>Language Code: "EN"; Country Code: "CA"</li>
 <ul><li>for English in Canada</li></ul>
 <li>Language Code: "FR"; Country Code: "CA"</li>
 <ul><li>for French in Canada</li></ul>
 <li>Language Code: "DE"; Country Code: "DE"</li>
 <ul><li>for German in Germany</li></ul>
 <li>Language Code: "ES"; Country Code: "ES"</li>
 <ul><li>for Spanish in Spain</li></ul>
 <li>Language Code: "FR"; Country Code: "FR"</li>
 <ul><li>for French in France</li></ul>
 <li>Language Code: "EN"; Country Code: "GB"</li>
 <ul><li>for English in Great Britain</li></ul>
 <li>Language Code: "EN"; Country Code: "IE"</li>
 <ul><li>for English in Ireland</li></ul>
 <li>Language Code: "IT"; Country Code: "IT"</li>
 <ul><li>for Italian in Italy</li></ul>
 <li>Language Code: "EN"; Country Code: "US"</li>
 <ul><li>for English in the United States</li></ul>
 </ul>
 <p>These pairs of language and country code can be used to create a valid locale for 
 use with the deCartaGeocoder.</p>
 * @brief Country and language locale identifier.
 */
@interface deCartaLocale : NSObject
{
    /*! 2-letter country code of the locale */
	NSString *_countryCode;

    /*! 2-letter language code of the locale */
	NSString *_languageCode;
}

/*! 2-letter country code of the locale */
@property(nonatomic, retain) NSString *countryCode;

/*! 2-letter language code of the locale */
@property(nonatomic, retain) NSString *languageCode;

/*!
 * Creates a deCartaLocale object using language and country information
 * @param inCountry 2-letter country code
 * @param inLanguage 2-letter language code
 * @return ID of the returned deCartaLocale object
 */
- (id) initWithCountryCode:(NSString *) inCountry andLanguageCode:(NSString *) inLanguage;

/*!
 * Compares an object to this one.
 * @param inObj Object to compare
 * @return TRUE if the inObj matches the current object
 */
- (BOOL) isEqual:(id) inObj;

@end
