//
//  EventListener.h
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deCartaEventListener.h"

/*!
 * @ingroup Event
 * iPhone Event Types
 */
typedef enum{
	TOUCH, /**< Touch event */
        MOVEEND, /**< Indicates the conclusion of a move action */
        ZOOMEND, /**< Indicates the conclusion of a zoom action */
        DOUBLECLICK, /**< Double-tap event */
        LONGTOUCH, /**< Touch-and-hold event */
        ROTATEEND, /**< Indicates the conclusion of a rotation action */
        TILTEND /**< Indicates the conclusion of a tilt action */
}EventTypeEnum;

/*!
 * @ingroup Event
 * @class deCartaEventSource
 * This protocol should be inherited by any object that is an event source.
 * Classes that are event sources (and inherited from this class) in the
 * deCarta iPhone API include deCartaCompass, deCartaInfoWindow,
 * deCartaMapView, deCartaPin, deCartaPolyline, and deCartaShape.
 * 
 * This protocol defines virtual functions which must be implemented by the
 * object which inherits from deCartaEventSource. As a result, not all 
 * classes which inherit from deCartaEventSource support the capturing of all
 * event types. See each respective class for details.
 * @brief A protocol to be used as a template for any class which is an event source
 */
@protocol deCartaEventSource <NSObject>

/*! A prototype for the addEventListener function for any class that inherits
 * from the deCartaEventSource protocol.
 */
-(BOOL)addEventListener:(deCartaEventListener *)listener forEventType:(int)eventType;

/*! A prototype for the removeEventListener function for any class that
 * inherits from the deCartaEventSource protocol.
 */
-(void)removeEventListener:(deCartaEventListener *)listener forEventType:(int)eventType;

/*! A prototype for the removeEventListeners function for any class that
 * inherits from the deCartaEventSource protocol.
 */
-(void)removeEventListeners:(int)eventType;

/*! A prototype for the executeEventListeners function for any class that
 * inherits from the deCartaEventSource protocol.
 */
-(void)executeEventListeners:(int)eventType withParam:(id)param;

@end
