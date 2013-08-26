//
//  deCartaIcon.h
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaXYInteger.h"


/*!
 * @ingroup Map
 * @class deCartaIcon
 * The deCartaIcon class is used to create custom icon objects that can be
 * overlayed on a deCartaMap in conjunction with a deCartaPin (a
 * dynamically created point representing a location on the map).
 * @brief An icon to overlay onto the map.
 */
@interface deCartaIcon : NSObject <NSCopying>{
	deCartaXYInteger * _size;
	UIImage * _image;
	deCartaXYInteger * _offset;
}
/*! The width(X) and height(Y) of the icon, in pixels */
@property(nonatomic,retain)deCartaXYInteger * size;

/*! The icon to display */
@property(nonatomic,retain)deCartaXYInteger * offset;

/*! 
 * Offset of the icon from the target position. A value of
 * X=20 and Y=30 means that the top-left corner of the icon would
 * be placed 20 pixels to the left and 30 pixels above the specified
 * position.
 */
@property(nonatomic,retain)UIImage * image;

/*!
 * Initializes the deCartaIcon object with an image, image size,
 * and screen coordinates.
 * @param image Source image for the icon
 * @param size Size of the icon (width and height), specified as a deCartaXYInteger
 * @param offset (X,Y) coordinate indicating the offset to the left and up at
 * which to place the top-left corner of the icon when rendering.
 * @return The ID of the created deCartaIcon object.
 */
-(id)initWithImage:(UIImage *)image size:(deCartaXYInteger *)size offset:(deCartaXYInteger *)offset;

/*!
 * Initializes the deCartaIcon object with an image, but does not specify
 * screen coordinates or image size.
 * @param image Source image for the icon
 * @return The Objective-C ID of the created deCartaIcon object.
 */
-(id)initWithImage:(UIImage *)image;



@end
