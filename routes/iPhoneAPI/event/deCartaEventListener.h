//
//  deCartaEventListener.h
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol deCartaEventSource;

/*!
 * @ingroup Event
 * Event Listener Callback Function
 */
typedef void (^CallbackFunction)(id<deCartaEventSource>,id);

/*!
 * @ingroup Event
 * @class deCartaEventListener
 * Any user-defined class which wants to receive call-backs when events
 * occur in the deCarta iPhone API should inherit from this class.
 * @brief Base class for deCarta iPhone API event listeners.
 */
@interface deCartaEventListener : NSObject {
	CallbackFunction _callback;
}
/*! The callback function that is executed when the API triggers an event. */
@property(nonatomic,retain,readonly) CallbackFunction callback;

/*! Initializes a deCartaEventListener object with a specified callback
 * function.
 * @param inCallback The callback function to execute when an event is
 * triggered.
 * @return Objective-C ID of the deCartaEventListener object.
 */
-(id)initWithCallback:(CallbackFunction)inCallback;

/*!
 * Sets the deCartaEventListener object's callback function.
 * @param inCallback The callback function to execute when an event is
 * triggered.
 * @return Objective-C ID of the deCartaEventListener object.
 */
+(id)eventListenerWithCallback:(CallbackFunction)inCallback;

@end
