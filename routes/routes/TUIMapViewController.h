//
//  TUIMapViewController.h
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUISpot.h"

@interface TUIMapViewController : UIViewController <TUISpotDelegate>

/**
 * Closes the master view when displayed
 */
-(void)closeMaster;

@end

