//
//  TUIRouteController.m
//  routes
//
//  Created by Diego Lafuente on 12/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIRouteController.h"

#pragma mark - Private interface
@interface TUIRouteController ()

@property (strong, nonatomic) TUIRoute *currentRoute;

@end

#pragma mark - Implementation
@implementation TUIRouteController
#pragma mark - Public methods
+ (TUIRouteController *)sharedInstance {
    static TUIRouteController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TUIRouteController alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.currentRoute = [TUIRoute emptyCircularRoute];
    });
    return sharedInstance;
}

-(TUISpot *)startSpot {
    return [_currentRoute startSpot];
}

-(TUISpot *)endSpot {
    return [_currentRoute endSpot];
}

-(TUISpot *)nextSpot:(BOOL)shouldMove {
    return [_currentRoute nextSpot:shouldMove];
}

-(void)reset {
    [_currentRoute reset];
}

-(void) flush {
    _currentRoute = [TUIRoute emptyCircularRoute];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TUIRouteFlushed"
     object:self];
}

-(void)addSpot:(TUISpot *)spot {
    [_currentRoute addSpot:spot];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TUISpotAdded"
     object:spot];
}

-(void)removeSpot:(TUISpot *)spot {
    [_currentRoute removeSpot:spot];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TUISpotRemoved"
     object:spot];
}

-(TUISpot *)spotForIndexPath:(NSIndexPath *)indexPath {
    return [_currentRoute spotForIndexPath:indexPath];
    
}

@end
