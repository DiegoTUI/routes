/*
 *  GEView.h
 *  Sunder
 *
 *  Created by Daniel Posluns on 2/7/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

@class GEView;
@class GEImpl;

@protocol GEViewDelegate <NSObject>

@optional
- (void)preEngineInit:(GEView *)ge;
- (void)engineInitialized:(GEView *)ge;

@end


@interface GEView : UIView
{
	BOOL				fixedCanvas;
	id<GEViewDelegate>	delegate;
	NSString			*resourceDirectoryPrefix;
	
@package
	GEImpl				*_geImpl;
}
@property (nonatomic, assign) id<GEViewDelegate> delegate;
@property (nonatomic, retain) NSString *resourceDirectoryPrefix;
@property (nonatomic, assign) BOOL fixedCanvas;
@property (nonatomic, readonly) float backingScale;
@property (nonatomic, readonly) float invBackingScale;
@property (nonatomic, readonly) BOOL isAnimating;

- (id)initWithFrame:(CGRect)aRect;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)initEngine;
- (void)shutDown;
- (void)startAnimation;
- (void)stopAnimation;

@end
