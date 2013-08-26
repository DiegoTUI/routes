//
//  deCartaFreeFormAddress.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaAddress.h"


/*!
 * @ingroup Location
 * @class deCartaFreeFormAddress
 * The deCartaFreeFormAddress class contains a string which represents a 
 * free-form address, which can be taken directly from the user, parsed, 
 * and used for geocoding. For free-form addresses, the DDS Web Services perform
 * parsing and geocoding.
 * @brief One-line string containing a free-form address.
 */
@interface deCartaFreeFormAddress : deCartaAddress
{
    /*! A string containing a free form address. */
	NSString *_freeFormAddress;
}

/*!
 * A string containing a free form address.
 */
@property(nonatomic, retain) NSString *freeFormAddress;

/*!
 * Initializes a deCartaFreeFormAddress object
 * @param inAddress String with free form address information
 * @return deCartaFreeFormAddress object
 */
- (id) initWithString:(NSString *) inAddress;

@end
