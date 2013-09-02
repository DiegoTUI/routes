//
//  DCMapPushpinDelegate.h
//  NavigationLib
//
//  Created by Daniel Posluns on 6/24/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCMapPushpin;

@protocol DCMapPushpinDelegate <NSObject>

@optional
- (void)pushpinSelected:(DCMapPushpin *)pushpin;

@end
