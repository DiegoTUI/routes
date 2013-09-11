//
//  TUIMapViewController.h
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUISpot.h"

@protocol TUIMapViewControllerDelegate;

@interface TUIMapViewController : UIViewController

@property (weak,nonatomic) id<TUIMapViewControllerDelegate> delegate;

/**
 * Adds a spot to the pin overlay setting its latitude, longitude and message
 * @return the added pin
 */
-(TUISpot *)addSpotOfType:(TUISpotType)type
           withLatitude:(double)latitude
              longitude:(double)longitude
             andName:(NSString *)name;

/**
 * Removes spot by reference
 */
-(void)removeSpot:(TUISpot *)spot;

/**
 * Closes the master view when displayed
 */
-(void)closeMaster;

@end

@protocol TUIMapViewControllerDelegate <NSObject>

-(void)aboutToRemoveSpot:(TUISpot *)spot;
-(void)aboutToRemoveAllSpots;
-(void)disableCells:(BOOL)cellsDisabled;
-(void)performedSegue:(NSString *)segueId;

@end
