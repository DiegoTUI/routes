//
//  deCartaAddress.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deCartaLocale.h"

/*!
 * @ingroup Location
 * @class deCartaAddress
 * The deCartaAddress class is the super class for address types.
 * deCartaStructuredAddress and deCartaFreeFormAddress are subclasses, which hold
 * either a structured address or a free-form address, respectively.
 * @brief Super class for deCartaStructuredAddress and deCartaFreeFormAddress classes 
 */
@interface deCartaAddress : NSObject
{
     /*! The region of interest, which defines parsing rules to be used with this address. */
	deCartaLocale *_locale;
}

/*! The region of interest, which defines parsing rules to be used with this address. */
@property (nonatomic, retain) deCartaLocale *locale;


@end

