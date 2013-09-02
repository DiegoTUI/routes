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

@interface TUINavViewController : DCNavViewController

@property (weak, nonatomic) id<TUINavViewControllerDelegate> delegate;

@end

@protocol TUINavViewControllerDelegate <NSObject>

-(void)closeButtonClicked;

@end
