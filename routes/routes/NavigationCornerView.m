//
//  NavigationCornerView.m
//  GeoStarter
//
//  Created by Daniel Posluns on 5/7/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import "NavigationCornerView.h"

#import <QuartzCore/QuartzCore.h>

static const float ROUND_CORNER_INSET = 0.25f;
static const int IMAGE_MARGIN = 4;
static const int TEXT_MARGIN = 4;
static const int FONT_SIZE = 12;

@implementation NavigationCornerView

@synthesize imgIcon;
@synthesize lblText;

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

- (void)configureView
{
	// Set up the rounded gradient background
	CAGradientLayer		*gradient = (CAGradientLayer *)self.layer;
	CAShapeLayer		*mask = [CAShapeLayer layer];
	CGMutablePathRef	path = CGPathCreateMutable();
	const float			dim = gradient.bounds.size.width;
	const float			inset = ROUND_CORNER_INSET * dim;
	CGPoint				points[] = {
							CGPointMake(dim, dim - inset),
							CGPointMake(dim, 0),
							CGPointMake(0, 0),
							CGPointMake(0, dim),
							CGPointMake(dim - inset, dim) };

	gradient.startPoint = CGPointMake(0.5f, 0);
	gradient.endPoint = CGPointMake(0.5f, 1.0f);
	startColor = [[UIColor grayColor] retain];
	endColor = [[UIColor blackColor] retain];
	isHighlighted = YES;
	[self setHighlighted:NO];
	
	CGPathAddLines(path, NULL, points, sizeof(points) / sizeof(points[0]));
	CGPathAddQuadCurveToPoint(path, NULL, dim, dim, dim, dim - inset);
	CGPathCloseSubpath(path);
	
	if (gradient.frame.origin.x > 0)
	{
		// Horizontally flip the gradient background for the top-right corner
		CGAffineTransform	flipTransform = CGAffineTransformMake(-1.0f, 0, 0, 1.0f, dim, 0);
		CGMutablePathRef	flipPath = CGPathCreateMutableCopyByTransformingPath(path, &flipTransform);
		
		CGPathRelease(path);
		path = flipPath;
	}
	
	mask.frame = gradient.bounds;
	mask.path = path;
	gradient.mask = mask;
	CGPathRelease(path);
	
	// Create the text label
	UIFont	*font = [UIFont systemFontOfSize:FONT_SIZE];
	int		textHeight = font.ascender - font.descender + 0.5f;
	CGRect	textFrame = self.bounds;
	
	textFrame.origin.y = CGRectGetMaxY(textFrame) - textHeight - TEXT_MARGIN;
	textFrame.size.height = textHeight;
	lblText = [[[UILabel alloc] initWithFrame:textFrame] autorelease];
	lblText.textAlignment = NSTextAlignmentCenter;
	lblText.font = font;
	lblText.textColor = [UIColor whiteColor];
	lblText.adjustsFontSizeToFitWidth = YES;
	lblText.minimumScaleFactor = 0.5f;
	lblText.opaque = NO;
	lblText.backgroundColor = [UIColor clearColor];
	
	// Create the image view
	CGRect	imageRect = CGRectInset(self.bounds, IMAGE_MARGIN, IMAGE_MARGIN);
	
	imageRect.size.height = textFrame.origin.y - imageRect.origin.y;
	imageRect = CGRectInset(imageRect, (imageRect.size.width - imageRect.size.height) * 0.5f, 0);
	imgIcon = [[[UIImageView alloc] initWithFrame:(CGRect)imageRect] autorelease];
	
	[self addSubview:imgIcon];
	[self addSubview:lblText];
	
	// Configure other elements of the view
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self configureView];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self configureView];
	}
	
	return self;
}

- (void)dealloc
{
	[startColor release];
	[endColor release];

	[super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setHighlighted:(BOOL)highlighted
{
	if (highlighted != isHighlighted)
	{
		CAGradientLayer		*gradient = (CAGradientLayer *)self.layer;
		UIColor				*start = startColor;
		UIColor				*end = endColor;
		
		if (highlighted)
		{
			end = startColor;
			start = endColor;
		}
		
		gradient.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)end.CGColor, nil];
		isHighlighted = highlighted;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setHighlighted:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setHighlighted:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL inRegion = [self pointInside:[(UITouch *)[touches anyObject] locationInView:self] withEvent:event];
	
	if (inRegion && [_delegate respondsToSelector:@selector(cornerViewPressed:)]) {
		[_delegate cornerViewPressed:self];
	}
    
	[self setHighlighted:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setHighlighted:[self pointInside:[(UITouch *)[touches anyObject] locationInView:self] withEvent:event]];
}

# pragma mark - Public methods

- (NSAttributedString *)formatValueForDisplay:(NSString *)value unit:(NSString *)unit
{
	NSString					*combinedString = unit ? [NSString stringWithFormat:@"%@ %@", value, unit] : value;
	NSMutableAttributedString	*attrText = [[[NSMutableAttributedString alloc] initWithString:combinedString] autorelease];
	
	[attrText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:FONT_SIZE] range:NSMakeRange(0, [value length])];
	
	return attrText;
}

@end
