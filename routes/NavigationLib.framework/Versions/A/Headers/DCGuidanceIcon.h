//
//  DCGuidanceIcon.h
//  NavigationLib
//
//  Created by Daniel Posluns on 6/3/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DCGuidanceConstants.h"

@protocol DCGuidanceSimpleIcon;

@protocol DCGuidanceIcon <NSObject>

- (DCGuidanceIconType)iconType;
- (int)legsMask;
- (int)exitLeg;
- (int)roundaboutExitNumber;
- (id<DCGuidanceSimpleIcon>)simpleIcon;
- (BOOL)isEqualToIcon:(id<DCGuidanceIcon>)icon;

+ (float)angleForLeg:(int)leg;

@end
