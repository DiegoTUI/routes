//
//  deCartaCircle.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaShape.h"
#import "deCartaPosition.h"
#import "deCartaLength.h"
#import "deCartaXYDouble.h"

/*!
 * @ingroup Map
 * @class deCartaCircle
 * deCartaCircle is an extension of deCartaShape, one that is specifically
 * geared towards displaying a circle overlay at a specific
 * coordinate on a deCartaMap. 
 * The deCartaCircle class inherits from the deCartaShape class, which
 * inherits from the deCartaEventSource class. So, deCartaCircle could
 * theoretically support event-capturing, but this functionality is not
 * implemented, so a deCartaCircle will not trigger any events.
 * @brief A circle object
 */
@interface deCartaCircle : deCartaShape {
	deCartaLength * _radius;
	deCartaPosition * _position;
	deCartaXYDouble * _mercXY;
}

/*! Radius of the circle
 * (Units of measure are defined within the deCartaLength class)
 */	
@property(nonatomic,retain)deCartaLength * radius;

/*! Center position of the circle */
@property(nonatomic,retain)deCartaPosition * position;

/*! @internal For internal API use only. */
@property(nonatomic,retain,readonly)deCartaXYDouble * mercXY;

/*!
 * Initialize the deCartaCircle object with a center position, radius, and name.
 * @param inPosition Geographic position of center of the circle
 * @param inRadius Radius of the circle
 * @param inName String name for the circle
 * @return Objective-C ID of the returned deCartaCircle object
 */
-(id)initWithPosition:(deCartaPosition *)inPosition radius:(deCartaLength *)inRadius name:(NSString *)inName;

#pragma mark -
#pragma mark @definition methods used only in API
-(void)renderGL:(deCartaXYDouble *)topLeftXY atZoom:(float)zoomLevel;

@end
