//
//  InfoWindow.h
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaXYFloat.h"
#import "deCartaXYDouble.h"
#import "deCartaPin.h"
#import "deCartaPosition.h"
#import "deCartaRotationTilt.h"


#define INFO_WINDOW_MAX_CHARS_PER_LINE 30
#define INFO_WINDOW_BACKGROUND_COLOR_CLICKED 0xfff5f5dc
#define INFO_WINDOW_BACKGROUND_COLOR_UNCLICKED 0xffe6e6e6

typedef enum{
    INFO_WINDOW_TEXT_ALIGN_LEFT,
    INFO_WINDOW_TEXT_ALIGN_CENTER
}deCartaInfoWindowTextAlignEnum;

/*!
 * @ingroup Map
 * @class deCartaInfoWindow
 * This class is a textbox for displaying simple information that can be displayed
 * on the map. Generally this info window will be associated with a specific
 * deCartaPin, and will be positioned above the pin. To have a deCartaInfoWindow
 * appear on the map, assign the deCartaMapView object's infoWindow property to
 * a specific deCartaInfoWindow object.
 *
 * The deCartaInfoWindow class inherits from the deCartaEventSource class, and
 * extends the class by adding functionality for triggering events. When TOUCH
 * event is detected on the deCartaMapView over the deCartaInfoWindow's
 * location, the deCartaInfoWindow will call it's listeners
 * (deCartaEventLister objects) with the TOUCH event type (defined by the
 * EventTypeEnum).
 * @brief An information text window that is displayed on the map.
 */
@interface deCartaInfoWindow : NSObject <deCartaEventSource>{
	deCartaPin * _associatedPin;
	BOOL _visible;
	deCartaXYDouble * _mercXY;
	deCartaPosition * _position;
	NSString * _message;
	deCartaXYFloat * _offset;
	deCartaRotationTilt * _offsetRotationTilt;
	int _backgroundColor;
	
	unsigned int _textureRef;
	BOOL _texImageChanged;
	CGRect _rect;
	
	NSMutableDictionary * _eventListeners;
    
    deCartaInfoWindowTextAlignEnum _textAlign;

}
/*! An XY pixel offset from the position on the map associated with this info
 * window to the bottom-center tip of the info window. Generally, this offset
 * is sufficient to place the info window just above the POI icon with which
 * this info window is associated.
 * Example: 0,0 - put bottom-center of info window directly on map location
 * Example: 10,20 - position bottom-center of info window to the left 0 pixels,
 * and up 20 pixels from the map location
 */
@property(nonatomic,retain,readonly) deCartaXYFloat * offset;

/*! The text to display in the info window. */
@property(nonatomic,retain) NSString * message;

/*! The geographic position on the map that this info window is associated with. */
@property(nonatomic,retain) deCartaPosition * position;

/*! TRUE to make the info window visible. */
@property(nonatomic,assign) BOOL visible;

/*! Background color of the info window in 0xXXRRGGBB format. */
@property(nonatomic,assign) int backgroundColor;

/*! The deCartaPin with which this info window is associated (if it has an associated pin) */
@property(nonatomic,retain) deCartaPin * associatedPin;

/*! The amount of rotation and tilt of this info window. See the deCartaRotationTilt class
 * for details on rotating or tilting the info window relative to the screen, or relative
 * to the map's rotation and tilt.
 */
@property(nonatomic,retain,readonly) deCartaRotationTilt * offsetRotationTilt;

/*! @internal For internal API use only */
@property(nonatomic,retain,readonly) deCartaXYDouble * mercXY;

/*! @internal For internal API use only
 * Image texture handle for openGL use
 */
@property(nonatomic,assign) unsigned int textureRef;

/*! @internal For internal API use only
 * Indicates that the image of the infowindow has been changed.
 */
@property(nonatomic,assign) BOOL texImageChanged;

/*! The rectangular bounds of the info window */
@property(nonatomic,assign,readonly)CGRect rect;

@property(nonatomic,assign)deCartaInfoWindowTextAlignEnum textAlign;

/*! Returns a pointer to this deCartaInfoWindow object.
 * @return Pointer to this deCartaInfoWindow object.
 */
+(deCartaInfoWindow *)getInfoWindowInstance;

/*!
 * Sets the rotation and tilt of the info window. See the deCartaRotationTilt class
 * for details about how to set the rotation and tilt of the info window relative to
 * the screen, or relative to the map's rotation and tilt.
 * @param offset The offset, in pixels, to place the info window relative to the corresponding
 * map location. Note that positive X,Y offset values give an offset that is up and to the left.
 * @param offsetRotationTilt The amount to rotate and tilt the info window.
 */
-(void)setOffset:(deCartaXYFloat *)offset andRotationTilt:(deCartaRotationTilt *)offsetRotationTilt;

#pragma mark -
#pragma mark @definition methods used only in API
/*! @internal For internal API use only. */
-(void)drawInfoWindow;

/*! @internal For internal API use only. */
-(CGRect)getInfoWindowRect;

@end
