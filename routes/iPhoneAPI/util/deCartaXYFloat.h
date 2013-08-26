//
//  deCartaXYFloat.h
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * ingroup Util
 * @class deCartaXYFloat
 * An object containing a 2-part coordinate, with X and Y values represented
 * in single-precision floating point. This is typically used to represent
 * screen position.
 * @brief X,Y floating-point coordinate pair (for screen position)
 */
@interface deCartaXYFloat : NSObject {
   /*! X component */
	float _x;

   /*! Y component */
	float _y;
}
/*! X component */
@property(nonatomic,assign) float x;

/*! Y component */
@property(nonatomic,assign) float y;

/*! Initializes the deCartaXYFloat object with X and Y coordinate values
 * @param x Floating point x value (horizontal position)
 * @param y Floating point y value (vertical position)
 * @return Objective-C ID of the deCartaXYFloat object.
 */
-(id) initWithXf:(float)x andYf:(float)y;

/*! Sets the deCartaXYFloat object's X and Y coordinate values
 * @param x Floating point x value (horizontal position)
 * @param y Floating point y value (vertical position)
 * @return Objective-C ID of the deCartaXYFloat object.
 */
+(id)XYWithX:(float)x andY:(float)y;

@end
