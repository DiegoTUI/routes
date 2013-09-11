//
//  NSString+Tui.m
//  routes
//
//  Created by Diego Lafuente on 11/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "NSString+Tui.h"

@implementation NSString (Tui)

-(NSString *)underscorify {
    NSMutableString *result = [[self lowercaseString] mutableCopy];
    [result replaceOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
    return result;
}

@end
