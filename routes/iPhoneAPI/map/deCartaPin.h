//
//  deCartaPin.h
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaIcon.h"
#import "deCartaXYDouble.h"
#import "deCartaRotationTilt.h"
#import "deCartaEventSource.h"
#import "deCartaPosition.h"
#import "deCartaPOI.h"

@class deCartaOverlay;

/*!
 * @ingroup Map
 * @class deCartaPin
 * Used to define a pin object to place at a specific location
 * on the map. A pin is stored in a deCartaOverlay object (see
 * deCartaOverlay for more information on how to use map overlays).
 *
 * The deCartaPin class inherits from the deCartaEventSource class, and
 * extends the class by adding functionality for triggering events. When TOUCH
 * event is detected on the deCartaMapView over the deCartaPin's location, 
 * the deCartaPin will call it's listeners (deCartaEventLister objects) with
 * the TOUCH event type (defined by the EventTypeEnum).
 * @brief A pin to place on a map.
 */
@interface deCartaPin : NSObject <deCartaEventSource>{
	deCartaIcon * _icon;
	deCartaXYDouble * _mercXY;
	NSString * _message;
	BOOL _visible;
	NSMutableDictionary * _eventListeners;
	deCartaOverlay * _ownerOverlay;
	
	deCartaRotationTilt * _rotationTilt;
	deCartaPOI * _poi;
    id _associatedObject;
	
}
/*!
 * The graphical icon (and display details) for the icon associated
 * with this pin.
 */
@property(nonatomic,retain)deCartaIcon * icon;

/*! A text string stored with this pin
 * (generally an address or POI name)
 */
@property(nonatomic,retain)NSString * message;

/*!
 * Set to TRUE to display this pin on the map.
 */
@property(nonatomic,assign)BOOL visible;

/*!
 * In order to display deCartaPin object on the map, they need to be
 * placed into a deCartaOverlay which is a container for one or more
 * deCartaPins, and then that overlay must be added to the overlays of the
 * deCartaMapView. Once added to an overlay, the deCartaPin object uses
 * this property to maintain a pointer the overlay in which it is contained.
 */
@property(nonatomic,retain)deCartaOverlay * ownerOverlay;

/*!
 * A tilt property for this pin, which defines how much to tilt the pin
 * relative to the map. See the deCartaRotiationTilt class for details about
 * defining tilt.
 */
@property(nonatomic,retain,readonly)deCartaRotationTilt * rotationTilt;

/*!
 * This property is deprecated, associatedObject should be used instead. 
 */
@property(nonatomic,retain)deCartaPOI * poi __attribute__((deprecated));

/*!
 * General object associated with this pin. The caller should be responsible to know the type infomation. 
 */
@property(nonatomic,retain)id associatedObject;

/*!
 * Initializes a deCartaPin with items that describe the pin's
 * graphic, text, and position.
 * @param position The geographic position at which to place the pin.
 * @param icon The graphic icon to display at this location. Note that
 *   an deCartaIcon object contains both a graphic and the offset for
 *   displaying the graphic relative to the map point.   
 * @param message A text message that is stored with the pin.
 * @param rt A tilt value for the pin. See the deCartaRotationTilt class
 *   for details about how tilt is defined.
 * @return Objective C ID of the initialized deCartaOverlay object
 */
-(id)initWithPosition:(deCartaPosition *)position icon:(deCartaIcon *)icon message:(NSString *)message rotationTilt:(deCartaRotationTilt *)rt;
-(deCartaPosition *)position;
-(void)setPosition:(deCartaPosition *)position;
/*! @internal internal use only */
-(deCartaXYDouble *)mercXY;
/*! @internal internal use only */
-(void)setMercXY:(deCartaXYDouble *)mercXY;

@end
