//
//  UIImage+Tui.m
//  routes
//
//  Created by Diego Lafuente on 29/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "UIImage+Tui.h"

@implementation UIImage (Tui)

+(UIImage *)imageNamedSmart:(NSString *)imageName {
    if ([[UIScreen mainScreen] scale] == 2.0) {
        imageName = [imageName stringByAppendingString:@"@2x"];
    }
    return [UIImage imageNamed:imageName];
}

@end
