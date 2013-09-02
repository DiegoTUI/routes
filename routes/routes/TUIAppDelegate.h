//
//  TUIAppDelegate.h
//  routes
//
//  Created by Diego Lafuente on 26/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NavigationLib/NavigationLib.h>

@interface TUIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(DCNavigationManager *)beginNavigationSessionWithConfig:(DCNavigationConfig *)navigationConfig;

@end
