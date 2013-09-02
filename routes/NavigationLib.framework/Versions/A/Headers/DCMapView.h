//
//  DCMapView.h
//  Sunder
//
//  Created by Daniel Posluns on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GEView.h"

@class CLHeading;
@class CLLocation;
@class DCMapImpl;
@class DCMapLaunchState;
@protocol DCMapDelegate;

@interface DCMapView : GEView
{
@private
	id<DCMapDelegate>	mapDelegate;
	DCMapLaunchState	*launchState;
	NSString			*persistKey;
	
@package
	DCMapImpl			*_dcmapImpl;
}

@property (nonatomic, assign) id<DCMapDelegate> mapDelegate;
@property (nonatomic, retain) DCMapLaunchState *launchState;
@property (nonatomic, retain) NSString *persistKey;
@property (nonatomic, readonly) int zoomLevel;
@property (nonatomic, assign) BOOL nightMode;
@property (nonatomic, assign) CGRect uiMargins;

- (id)initWithFrame:(CGRect)aRect;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)saveState;
- (void)animateToOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration;
- (void)setUIMargins:(CGRect)rect animationTime:(float)time;

- (void)zoomStep:(BOOL)zoomIn;
- (void)toggleOverhead;

@end
