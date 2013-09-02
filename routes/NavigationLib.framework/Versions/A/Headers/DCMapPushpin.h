//
//  DCMapPushpin.h
//  NavigationLib
//
//  Created by Daniel Posluns on 6/24/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@class DCMapPushpin;
@class DCMapPushpinImpl;
@class DCMapView;
@protocol DCMapPushpinDelegate;

typedef void (^DCPushpinUpdateFn)(DCMapPushpin *);

@interface DCMapPushpin : NSObject
{
@package
	DCMapPushpinImpl	*_pushpinImpl;
}
@property (nonatomic, readonly) DCMapView *owningMap;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) CGPoint viewHeadPosition;
@property (nonatomic, assign) id<DCMapPushpinDelegate> delegate;
@property (nonatomic, retain) UIColor *headColor;
@property (nonatomic, assign) BOOL visible;

- (id)initWithMap:(DCMapView *)mapView location:(CLLocationCoordinate2D)coord initiallyVisible:(BOOL)visible;
- (void)animateEntry;
- (void)animateEntryWithOrderDelay:(int)orderDelay;
- (void)setVisible:(BOOL)visible animated:(BOOL)animated orderDelay:(int)orderDelay;
- (void)killWithAnimation:(BOOL)animated;

- (void)setFlagWithColor:(UIColor *)color;
- (void)setFlagWithImage:(UIImage *)image;
- (void)clearFlag;
- (BOOL)isFlag;

// Release the returned object to stop receiving updates
- (id)registerForPositionUpdatesWithCallback:(DCPushpinUpdateFn)callback;

+ (UIColor *)defaultHeadColor;

@end
