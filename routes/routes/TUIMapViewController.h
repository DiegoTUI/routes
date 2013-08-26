//
//  TUIMapViewController.h
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TUIMapViewController : UIViewController

-(void)addPinAtLatitude:(double)latitude
           andLongitude:(double)longitude;

-(void)closeMaster;

@end
