//
//  NSString+Tui.h
//  routes
//
//  Created by Diego Lafuente on 11/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tui)

/**
 * Turns "A String like This" into "a_string_like_this".
 * @return a singleton.
 */
-(NSString *)underscorify;

@end
