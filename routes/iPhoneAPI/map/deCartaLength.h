//
//  Length.h
//  iPhoneApp
//
//  Created by Z.S. on 2/4/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @ingroup Map
 * Units of Measure enumerated data type */
typedef enum {
	M, /**< Meters */
	KM, /**< Kilometers */
	MI /**< Miles */
} UOM;

/*! 
 * @ingroup Map
 * @class deCartaLength
 * An object representing a real-world distance. This class contains both the
 * measurement and the corresponding units of measure.
 * @brief Real-world distance (in M, KM, or MI)
 */
@interface deCartaLength : NSObject {
        /*! Distance as a double-precision floating-point number */
	double _distance;

	/*! Units of measure (M, KM, MI) */
	UOM _uom;
}

/*! Distance as a double-precision floating-point number */
@property(nonatomic,assign) double distance;

/*! Units of measure (M, KM, MI) */
@property(nonatomic,assign) UOM uom;

/*!
 * Initialize the deCartaLength object with a distance and unit of measure.
 * @param distance Distance as a double-precision floating-point number.
 * @param uom Unit of measure: M, KM, or MI
 * @return Objective-C ID of the returned deCartaLength object
 */
-(id)initWithDistance:(double)distance andUOM:(UOM)uom;

/*!
 * Converts a deCartaLength object from it's current unit of measure (M, KM, or MI)
 * to Meters
 * @return The deCartaLength, converted to length in meters
 */
-(double)toMeters;

@end
