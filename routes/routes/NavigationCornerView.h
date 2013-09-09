//
//  NavigationCornerView.h
//  GeoStarter
//
//  Created by Daniel Posluns on 5/7/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CornerViewDelegate;

@interface NavigationCornerView : UIView
{
	UIImageView				*imgIcon;
	UILabel					*lblText;
	UIColor					*startColor;
	UIColor					*endColor;
	BOOL					isDestination;
	BOOL					isHighlighted;
}
@property (nonatomic, assign) id<CornerViewDelegate> delegate;
@property (nonatomic, readonly) UIImageView *imgIcon;
@property (nonatomic, readonly) UILabel *lblText;

- (NSAttributedString *)formatValueForDisplay:(NSString *)value unit:(NSString *)unit;

@end

@protocol CornerViewDelegate <NSObject>

@optional
- (void)cornerViewPressed:(NavigationCornerView *)sender;

@end