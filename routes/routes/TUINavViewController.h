//
//  TUINavViewController.h
//  routes
//
//  Created by Diego Lafuente on 02/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NavigationLib/NavigationLib.h>

@protocol TUINavViewControllerDelegate;

typedef enum NightModeOption {
	NightModeOptionAutomatic,
	NightModeOptionDay,
	NightModeOptionNight
} NightModeOption;

@interface TUINavViewController : DCNavViewController
//delegate for closing the view
@property (weak, nonatomic) id<TUINavViewControllerDelegate> delegate;
// Navigation manager and updates
@property (nonatomic, readonly) DCNavigationManager *navigation;
@property (nonatomic, readonly) DCNavigationUpdate *lastUpdate;
@property (nonatomic, retain) DCGuidanceConfig *guidanceConfig;

@end

@protocol TUINavViewControllerDelegate <NSObject>

-(void)closeButtonClicked;

@end
