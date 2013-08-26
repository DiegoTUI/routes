//
//  deCartaXYDouble.h
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @ingroup Util
 * @class deCartaXYDouble
 * An object containing a 2-part coordinate, with X and Y values represented
 * in double-precision floating point. This is typically used for storing
 * real-word geographic coordinates.
 * @brief X,Y double-precision coordinate pair (for geo-coordinates)
 */
@interface deCartaXYDouble : NSObject {
   /*! X component */
	double _x;

   /*! Y component */
	double _y;
}
/*! X component */
@property(nonatomic,assign) double x;

/*! Y component */
@property(nonatomic,assign) double y;

/*! Initializes the deCartaXYDouble object with X and Y coordinate values */
/*! Initializes the deCartaXYDouble object with X and Y coordinate values
 * @param x Floating point x value (latitude)
 * @param y Floating point y value (longitude)
 * @return Objective-C ID of the deCartaXYDouble object.
 */
-(id) initWithXd:(double)x andYd:(double)y;

/*! Sets the deCartaXYDouble object's X and Y coordinate values
 * @param x Floating point x value (latitude)
 * @param y Floating point y value (longitude)
 * @return Objective-C ID of the deCartaXYDouble object.
 */
+(id)XYWithX:(double)x andY:(double)y;

@end
