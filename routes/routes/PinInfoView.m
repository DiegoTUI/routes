//
//  PinInfoView.m
//  GeoStarter
//
//  Created by Daniel Posluns on 6/24/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import "PinInfoView.h"

#import <NavigationLib/NavigationLib.h>

static const float VIEW_MARGIN = 2.0f;
static const float ELEMENT_MARGIN = 8.0f;
static const float CORNER_RADIUS_FACTOR = 0.25f;
static const float BG_MARGIN_FACTOR = 0.25f;
static const float BG_TAIL_HEIGHT_FACTOR = 0.75f;
static const float BG_TAIL_WIDTH_FACTOR = 0.5f;
static const float BUBBLE_STROKE_WIDTH = 1.0f;


#pragma mark - PinInfoView

@implementation PinInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithPushpin:(DCMapPushpin *)pushpin message:(NSString *)message delegate:(id<PinInfoViewDelegate>)delegate;
{
	// Calculate the size of the window by computing the size of the string when it's rendered
	UIButton		*btnDisclose = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	const float		fontSize = [UIFont labelFontSize];
	UIFont			*font = [UIFont systemFontOfSize:fontSize];
	CGSize			containerViewSize = pushpin.owningMap.frame.size;
	const float		maxLabelWidth = MIN(containerViewSize.width, containerViewSize.height) * 0.75f;
	CGSize			textSize = [message sizeWithFont:font constrainedToSize:CGSizeMake(maxLabelWidth, maxLabelWidth)];
	const float		width = textSize.width + 3.0f * ELEMENT_MARGIN + btnDisclose.frame.size.width;
	const float		requiredHeight = MAX(textSize.height, btnDisclose.frame.size.height);
	const float		height = requiredHeight + 2.0f * ELEMENT_MARGIN + BG_TAIL_HEIGHT_FACTOR * fontSize;
	CGRect			rect = CGRectMake(0, 0, width + VIEW_MARGIN * 2.0f, height + VIEW_MARGIN * 2.0f);
	
	if (self = [super initWithFrame:rect])
	{
		// Set member variables
		pinInfoDelegate = delegate;
		baseSize = fontSize;
		text = [message retain];
		textFont = [font retain];
		pin = [pushpin retain];
		textRect = CGRectMake(ELEMENT_MARGIN + VIEW_MARGIN,
			ELEMENT_MARGIN + VIEW_MARGIN + (requiredHeight - textSize.height) * 0.5f,
			textSize.width,
			textSize.height);
		
		CGPoint		viewHeadPosition = pushpin.viewHeadPosition;
		float		anchorX = 0.5f;
		
		// Adjust the anchor point left or right as necessary to try to keep the view on the screen
		rect.origin.x = viewHeadPosition.x - rect.size.width * 0.5f;
		
		if (rect.origin.x < 0)
		{
			const float		triangleLeft = viewHeadPosition.x - BG_TAIL_WIDTH_FACTOR * baseSize * 0.5f;
			const float		maxX = triangleLeft - VIEW_MARGIN - BUBBLE_STROKE_WIDTH - ELEMENT_MARGIN;
			const float		repositionX = MIN(maxX, 0);
			
			anchorX = 0.5f - (repositionX - rect.origin.x) / rect.size.width;
		}
		else if (CGRectGetMaxX(rect) > containerViewSize.width)
		{
			const float		triangleRight = viewHeadPosition.x + BG_TAIL_WIDTH_FACTOR * baseSize * 0.5f;
			const float		minX = triangleRight + VIEW_MARGIN + BUBBLE_STROKE_WIDTH + ELEMENT_MARGIN;
			const float		repositionX = MAX(minX, containerViewSize.width);
			
			anchorX = (viewHeadPosition.x - (repositionX - rect.size.width)) / rect.size.width;
		}

		// Set up the main layer
		self.layer.position = pushpin.viewHeadPosition;
		self.layer.anchorPoint = CGPointMake(anchorX, 1.0f);
		self.layer.affineTransform = CGAffineTransformMakeScale(0, 0);
		self.opaque = NO;
		[self.layer setNeedsDisplay];
		
		// Set up the disclose button
		btnDisclose.center = CGPointMake(btnDisclose.frame.size.width * 0.5f + textSize.width + 2.0f * ELEMENT_MARGIN + VIEW_MARGIN,
			VIEW_MARGIN + ELEMENT_MARGIN + requiredHeight * 0.5f);
		[btnDisclose addTarget:self action:@selector(disclosePressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:btnDisclose];

		// Update the view's position whenever the pin moves
		positionUpdateConnection = [pin registerForPositionUpdatesWithCallback:^(DCMapPushpin *p)
		{
			self.layer.position = p.viewHeadPosition;
		}];
		
		// Animate opening
		[UIView animateWithDuration:0.25f animations:^{
			self.layer.affineTransform = CGAffineTransformMakeScale(1.0f, 1.0f);
		}];
	}
	
	return self;
}

- (void)dealloc
{
	[pin release];
	[positionUpdateConnection release];
	[text release];
	[textFont release];

	[super dealloc];
}

- (void)close
{
	[UIView animateWithDuration:0.25f animations:^{
		self.layer.affineTransform = CGAffineTransformMakeScale(0, 0);
	}
	completion:^(BOOL finished) {
		[positionUpdateConnection release];
		positionUpdateConnection = nil;
		[self removeFromSuperview];
	}];
}

- (void)disclosePressed:(id)sender
{
	if ([pinInfoDelegate respondsToSelector:@selector(pinInfoView:pressedDiscloseButtonForPin:)])
	{
		[pinInfoDelegate pinInfoView:self pressedDiscloseButtonForPin:pin];
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGPathRef		bubblePath;
	const float		inset = VIEW_MARGIN * 2.0f + BUBBLE_STROKE_WIDTH * 2.0f;
	CGRect			clipBox = CGContextGetClipBoundingBox(ctx);
	CGRect			bbox = CGRectInset(clipBox, inset, inset);
	const float		tailHeight = BG_TAIL_HEIGHT_FACTOR * baseSize;
	const float		tailWidth = BG_TAIL_WIDTH_FACTOR * baseSize;
	CGRect			bodyBox = CGRectMake(bbox.origin.x, bbox.origin.y, bbox.size.width, bbox.size.height - tailHeight);
	UIBezierPath	*roundedRect = [UIBezierPath bezierPathWithRoundedRect:bodyBox cornerRadius:baseSize * CORNER_RADIUS_FACTOR];
	const float		tailCenterX = clipBox.size.width * layer.anchorPoint.x;
	const float		boxBottomY = CGRectGetMaxY(bodyBox);
	const CGPoint	tailPoints[] =
						{
							CGPointMake(tailCenterX - tailWidth * 0.5f, boxBottomY),
							CGPointMake(tailCenterX + tailWidth * 0.5f, boxBottomY),
							CGPointMake(tailCenterX, boxBottomY + tailHeight)
						};

	CGContextAddPath(ctx, roundedRect.CGPath);
	CGContextAddLines(ctx, tailPoints, 3);
	CGContextClosePath(ctx);
	bubblePath = CGContextCopyPath(ctx);

	CGContextSaveGState(ctx);
	CGContextSetShadow(ctx, CGSizeMake(0, 2.0f), 2.0f);
	
	CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1);
	CGContextSetLineWidth(ctx, 2.0f);
	CGContextStrokePath(ctx);
	
	CGContextRestoreGState(ctx);
	CGContextAddPath(ctx, bubblePath);
	
	CGColorRef		startColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor;
	CGColorRef		endColor = [UIColor colorWithRed:0.75f green:0.75f blue:1.0f alpha:1.0f].CGColor;
	NSArray			*colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
	const CGFloat	locations[] = { 0.0f, 1.0f };
	CGGradientRef	gradient = CGGradientCreateWithColors(NULL, (CFArrayRef)colors, locations);
	
	CGContextClip(ctx);
	CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0.5f, bbox.origin.y), CGPointMake(0.5f, bbox.origin.y + bbox.size.height), 0);
	
	UIGraphicsPushContext(ctx);
	[text drawInRect:textRect withFont:textFont lineBreakMode:NSLineBreakByWordWrapping];
	UIGraphicsPopContext();
	
	CGGradientRelease(gradient);
	CGPathRelease(bubblePath);
}


@end
