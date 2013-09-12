//
//  NSArray+TUI.m
//  routes
//
//  Created by Diego Lafuente on 12/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "NSArray+TUI.h"

@implementation NSArray (TUI)

-(NSArray *)arrayByRemovingObject:(id)anObject {
    if (anObject == nil) {
        return [self copy];
    } 
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self];
    [newArray removeObject:anObject];
    return [NSArray arrayWithArray:newArray];
}

@end
