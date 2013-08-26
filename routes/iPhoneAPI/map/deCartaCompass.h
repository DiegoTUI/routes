//
//  Compass.h
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaEventSource.h"
#import "deCartaEventListener.h"
#import "deCartaXYInteger.h"
#import "deCartaXYFloat.h"

/*!
 * @ingroup Map
 * Enumerated type used to identify which quandrant of the screen is used
 * to place the compass. */
typedef enum{
	COMPASS_TOP_LEFT, /**< Indicates placement of compass in the top-left region of the screen */
	COMPASS_TOP_RIGHT, /**< Indicates placement of compass in the top-right region of the screen */
	COMPASS_BOTTOM_LEFT, /**< Indicates placement of compass in the bottom-left region of the screen */
	COMPASS_BOTTOM_RIGHT /**< Indicates placement of compass in the bottom-right region of the screen */
}deCartaCompassLocationEnum;

/*!
 * @ingroup Map
 * @class deCartaCompass
 * Compass display object which indicates the current map orientation on the map.
 *
 * The deCartaCompass class inherits from the deCartaEventSource class, and
 * extends the class by adding functionality for triggering events. When TOUCH
 * event is detected on the deCartaMapView over the deCartaCompass's
 * location, the deCartaCompass will call it's listeners
 * (deCartaEventLister objects) with the TOUCH event type (defined by the
 * EventTypeEnum).
 * @brief Compass Map Overlay
 */
@interface deCartaCompass : NSObject <deCartaEventSource>{
	float _vertexN[6];
	float _vertexS[6];
	int _colorN;
	int _colorS;
	deCartaXYInteger * _size;
	deCartaXYInteger * _offset;
	deCartaCompassLocationEnum _compassLocation;
	BOOL _visible;
	NSMutableDictionary * _eventListeners;
}
/*! The color of the north-facing point of the compass control. 
 * Format: 0xXXRRGGBB
 */
@property(nonatomic,assign)int colorN;

/*! The color of the south-facing point of the compass control. 
 * Format: 0xXXRRGGBB
 */
@property(nonatomic,assign)int colorS;

/*! Size, in pixels, of the compass rose to display. */
@property(nonatomic,retain)deCartaXYInteger * size;

/*!
 * Offset from the target screen position to the top-left of
 * the compass rose display. A value of X=20, Y=30 means that
 * the top-left corner of the compass is 20 pixels left, and
 * 30 pixels up from the target position.
 */
@property(nonatomic,retain)deCartaXYInteger * offset;

/*!
 * The compass location, specified by the #deCartaCompassLocationEnum
 * enumerated type, indicating whether the compass should be placed
 * in the top-left, top-right, bottom-left, or bottom-right of the 
 * map display.
 */
@property(nonatomic,assign)deCartaCompassLocationEnum compassLocation;

/*!
 * Visibility setting for the compass. Set to FALSE to hide the compass
 */
@property(nonatomic,assign)BOOL visible;

/*!
 * Initialize the compass object with a size, offset, and general
 * location on the screen at which to place it.
 * @param size Size of the compass rose (width and height) in pixels
 * @param offset Offset from the target screen position to the top-left of
 * the compass rose display
 * @param compassLocation Compass location on the screen top-left, top-right, bottom-left, or bottom-right
 * @return Objective-C ID of the returned compass object.
 */
-(id)initWithSize:(deCartaXYInteger *)size offset:(deCartaXYInteger *)offset compassLocation:(deCartaCompassLocationEnum)compassLocation;

#pragma mark -
#pragma mark @definition methods used only in API
/*!
 * @internal For internal API use only. 
 */
-(void)renderGL;

/*!
 * @internal For internal API use only. 
 */
-(BOOL)snapTo:(deCartaXYFloat *)screenXY displaySize:(deCartaXYInteger *)displaySize;

/*!
 * @internal For internal API use only.
 */
-(deCartaXYInteger *)getScreenXY:(deCartaXYInteger *)displaySize;

@end
