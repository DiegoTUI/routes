//
//  TUIMapViewController.h
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TUIMapViewController : UIViewController

/**
 * Adds a pin to the pin overlay setting its latitude and longitude
 * @return the added pin
 */
-(deCartaPin *)addPinAtLatitude:(double)latitude
                   andLongitude:(double)longitude;

/**
 * Removes pin by reference
 */
-(void)removePin:(deCartaPin *)pin;

/**
 * Closes the master view when displayed
 */
-(void)closeMaster;

@end
