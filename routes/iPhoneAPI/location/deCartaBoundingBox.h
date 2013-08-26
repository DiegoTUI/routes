//
//  deCartaBoundingBox.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deCartaPosition.h"

/*!
 * @ingroup Location
 * @class deCartaBoundingBox
 * The BoundingBox class marks a rectangular geography. The extents
 * are marked by two deCartaPositions located at the upper-right
 * (maximum) and lower-left (minimum) locations.
 * @brief A rectangular geographic area.
 */
@interface deCartaBoundingBox : NSObject
{
    /*! Lower-left corner of bounding box */
	deCartaPosition *_minPosition;

    /*! Upper-right corner of bounding box */
	deCartaPosition *_maxPosition;
}

/*! The upper-right corner of the bounding box */
@property(nonatomic, retain) deCartaPosition *maxPosition;

/*! The lower-left corner of the bounding box */
@property(nonatomic, retain) deCartaPosition *minPosition;

/*!
 * @param min deCartaPosition object indicating the lower-left corner of the bounding box
 * @param max deCartaPosition object indicating the upper-right corner of the bounding box
 * @return A deCartaBoundingBox object.
 */
- (id) initWithMin:(deCartaPosition *) min andMax:(deCartaPosition *) max;

/*!
 * Retrieve the center position of the bounding box.
 * @return deCartaPosition object that is the calculated center point of the BoundingBox
 */
- (deCartaPosition *) getCenterPosition;

/*!
 * Check if a given Position is within the BoundingBox
 * @param pos The geographic location (lat, lon) to check
 * @return boolean true if located within the BoundingBox, false if located outside of the BoundingBox
 */
- (BOOL) contains:(deCartaPosition *) pos;
@end
