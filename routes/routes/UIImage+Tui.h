//
//  UIImage+Tui.h
//  routes
//
//  Created by Diego Lafuente on 29/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tui)

/**
 * Does the same as imageNamed, but right.
 * @return a UIImage.
 */
+(UIImage *)imageNamedSmart:(NSString *)imageName;

@end
