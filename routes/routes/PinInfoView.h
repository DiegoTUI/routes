//
//  PinInfoView.h
//  GeoStarter
//
//  Created by Daniel Posluns on 6/24/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCMapPushpin;
@class PinInfoView;

@protocol PinInfoViewDelegate <NSObject>
@optional
- (void)pinInfoView:(PinInfoView *)piv pressedDiscloseButtonForPin:(DCMapPushpin *)pin;

@end

@interface PinInfoView : UIView
{
	DCMapPushpin				*pin;
	id<PinInfoViewDelegate>		pinInfoDelegate;
	id							positionUpdateConnection;
	NSString					*text;
	UIFont						*textFont;
	CGRect						textRect;
	float						baseSize;
}

- (id)initWithPushpin:(DCMapPushpin *)pushpin message:(NSString *)message delegate:(id<PinInfoViewDelegate>)delegate;
- (void)close;

@end
