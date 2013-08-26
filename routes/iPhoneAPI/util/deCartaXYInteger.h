//
//  deCartaXYInteger.h
//  deCartaLibrary
//
//  Created by S.G. on 10/3/08.
//  Copyright 2008-09 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 * @ingroup Util
 * @class deCartaXYInteger
 * An object containing a 2-part coordinate, with X and Y values represented as
 * integers. Usually used to represent screen size.
 * @brief X,Y integer coordinate pair
 */
@interface deCartaXYInteger : NSObject <NSCopying>
{
    /*! Horizontal pixel value */
	int _x;

    /** Vertical pixel value */
	int _y;
}

/*! Horizontal pixel value */
@property (nonatomic, assign) int x;

/*! Vertical pixel value */
@property (nonatomic, assign) int y;

/*! Initalizes the deCartaXYInteger object with X and Y values
 * @param x X Value (width)
 * @param y Y Value (height)
 * @return Objective-C ID of the deCartaXYInteger object returned
 */
-(id) initWithXi:(int)x andYi:(int)y;

/*! Sets the deCartaXYInteger's X and Y values
 * @param x X Value (width)
 * @param y Y Value (height)
 * @return Objective-C ID of the deCartaXYInteger object returned
 */
+(id)XYWithX:(int)x andY:(int)y;

@end
