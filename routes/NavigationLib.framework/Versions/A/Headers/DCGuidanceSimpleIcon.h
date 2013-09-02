//
//  DCGuidanceIcon.h
//  NavigationLib
//
//  Created by Daniel Posluns on 5/22/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DCGuidanceConstants.h"

@protocol DCGuidanceSimpleIcon <NSObject>

- (DCGuidanceSimpleIconDirection)simpleDirection;
- (BOOL)isRoundabout;

@end
