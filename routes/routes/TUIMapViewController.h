//
//  TUIMapViewController.h
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIPin.h"

@protocol TUIMapViewControllerDelegate;

@interface TUIMapViewController : UIViewController

@property (weak,nonatomic) id<TUIMapViewControllerDelegate> delegate;

/**
 * Adds a pin to the pin overlay setting its latitude, longitude and message
 * @return the added pin
 */
-(TUIPin *)addPinOfType:(TUIPinType)type
           withLatitude:(double)latitude
              longitude:(double)longitude
             andMessage:(NSString *)message;

/**
 * Removes pin by reference
 */
-(void)removePin:(TUIPin *)pin;

/**
 * Closes the master view when displayed
 */
-(void)closeMaster;

@end

@protocol TUIMapViewControllerDelegate <NSObject>

-(void)aboutToRemovePin:(TUIPin *)pin;
-(void)aboutToRemoveAllPins;

@end
