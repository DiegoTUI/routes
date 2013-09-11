//
//  TUINavViewController.h
//  routes
//
//  Created by Diego Lafuente on 02/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NavigationLib/NavigationLib.h>

@protocol TUIXploreViewControllerDelegate;

typedef enum NightModeOption {
	NightModeOptionAutomatic,
	NightModeOptionDay,
	NightModeOptionNight
} NightModeOption;

@interface TUIXploreViewController : DCNavViewController

//delegate for closing the view
@property (weak, nonatomic) id<TUIXploreViewControllerDelegate> delegate;
// Navigation manager and updates
@property (strong, nonatomic, readonly) DCNavigationManager *navigation;
@property (strong, nonatomic, readonly) DCNavigationUpdate *lastUpdate;
@property (strong, nonatomic) DCGuidanceConfig *guidanceConfig;
// Route points (array of TUISpots)
@property (strong, nonatomic) deCartaOverlay *routeSpots;


@end

@protocol TUIXploreViewControllerDelegate <NSObject>

-(void)closeButtonClicked;

@end
