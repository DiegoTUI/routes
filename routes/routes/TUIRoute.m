//
//  TUIRoute.m
//  routes
//
//  Created by Diego Lafuente on 12/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIRoute.h"
#import "NSArray+TUI.h"


#pragma mark - Private interface
@interface TUIRoute()

@property (strong,nonatomic) NSArray *spots;
@property (strong, nonatomic) TUISpot *currentSpot;
@property (nonatomic) BOOL isCircular;

-(void)updateCurrentSpot;

@end

#pragma mark - Implementation
@implementation TUIRoute

#pragma mark - Public methods
+(TUIRoute *)emptyRoute {
    TUIRoute *emptyRoute = [[TUIRoute alloc] init];
    emptyRoute.spots = [NSArray array];
    emptyRoute.isCircular = NO;
    return emptyRoute;
}

+(TUIRoute *)emptyCircularRoute {
    TUIRoute *emptyRoute = [[TUIRoute alloc] init];
    emptyRoute.spots = [NSArray array];
    emptyRoute.isCircular = YES;
    return emptyRoute;
}

-(TUISpot *)startSpot {
    TUISpot *startSpot = nil;
    if ([_spots count]) {
        startSpot = _spots[0];
    }
    return startSpot;
}

-(TUISpot *)endSpot {
    TUISpot *endSpot = nil;
    if ([_spots count]) {
        endSpot = _isCircular ? _spots[0] : [_spots lastObject];
    }
    return endSpot;
}

-(TUISpot *)nextSpot:(BOOL)shouldMove {
    NSInteger currentIndex = [_spots indexOfObject:_currentSpot];
    if (currentIndex == NSNotFound) {
        return nil;
    }
        
    if (currentIndex == ([_spots count]-1)) {
        if (shouldMove) {
            _currentSpot = nil;
        }
        return _isCircular ? _spots[0] : nil;
    }
    if (shouldMove) {
        _currentSpot = _spots[currentIndex + 1];
    }
    return _spots[currentIndex + 1];
}

-(void)reset {
    _currentSpot = _spots[0];
}

-(void)addSpot:(TUISpot *)spot {
    _spots = [_spots arrayByAddingObject:spot];
    [self updateCurrentSpot];
}

-(void)removeSpot:(TUISpot *)spot {
    if (_currentSpot == spot) {
        _currentSpot = nil;
    }
    _spots = [_spots arrayByRemovingObject:spot];
    [self updateCurrentSpot];
}

-(TUISpot *)spotForIndexPath:(NSIndexPath *)indexPath {
    for (TUISpot *spot in _spots) {
        if (spot.indexPath && [spot.indexPath isEqual:indexPath]) {
            return spot;
        }
    }
    return nil;
}

#pragma mark - Private methods
-(void)updateCurrentSpot {
    if (_currentSpot == nil) {
        if ([_spots count]) {
            _currentSpot = _spots[0];
        }
    }
}

@end
