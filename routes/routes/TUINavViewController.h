//
//  TUINavViewController.h
//  routes
//
//  Created by Diego Lafuente on 02/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TUINavViewControllerDelegate;

@interface TUINavViewController : UIViewController

@property (weak, nonatomic) id<TUINavViewControllerDelegate> delegate;

@end

@protocol TUINavViewControllerDelegate <NSObject>

-(void)closeButtonClicked;

@end
