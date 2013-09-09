//
//  FormatUtils.m
//  GeoStarter
//
//  Created by Daniel Posluns on 5/16/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import "FormatUtils.h"

// NOTE: We do not bother providing dealloc methods for any of these private classes because they are all autoreleased,
// and none of their members are ever retained.

@interface TimeRemainingPieces : NSObject
{
@public
	NSString *value;
	NSString *unit;
	NSString *subValue;
	NSString *subUnit;
	NSString *combinedString;
}
@end

@implementation TimeRemainingPieces

- (id)initWithSeconds:(int)seconds
{
	if (self = [super init])
	{
		if (seconds >= 86400)
		{
			int		days = seconds / 86400;
			int		hours = (seconds % 86400) / 3600;
			
			value = [NSString stringWithFormat:@"%d", days];
			unit = @"d";
			subValue = [NSString stringWithFormat:@"%d", hours];
			subUnit = @"h";
		}
		else if (seconds >= 3600)
		{
			int		hours = seconds / 3600;
			int		minutes = (seconds % 3600) / 60;
			
			value = [NSString stringWithFormat:@"%d", hours];
			unit = @"h";
			subValue = [NSString stringWithFormat:@"%d", minutes];
			subUnit = @"m";
		}
		else
		{
			int		minutes = seconds / 60;
			
			value = [NSString stringWithFormat:@"%d", (minutes > 0 ? minutes : 1)];
			unit = @" min";
		}
		
		if (subValue)
		{
			combinedString = [NSString stringWithFormat:@"%@%@ %@%@", value, unit, subValue, subUnit];
		}
		else
		{
			combinedString = [NSString stringWithFormat:@"%@%@", value, unit];
		}
	}

	return self;
}

@end

@interface ArrivalTimePieces : NSObject
{
@public
	NSString	*timeString;
	NSRange		dataRange;
}

@end

@implementation ArrivalTimePieces

- (id)initWithSeconds:(int)seconds
{
	if (self = [super init])
	{
		NSDate				*arrivalTime = [NSDate dateWithTimeIntervalSinceNow:seconds];
		NSDateFormatter		*formatter = [[[NSDateFormatter alloc] init] autorelease];
		
		[formatter setDateStyle:NSDateFormatterNoStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		timeString = [formatter stringFromDate:arrivalTime];
		dataRange = [timeString rangeOfString:[formatter AMSymbol]];
		
		if (dataRange.location == NSNotFound)
		{
			dataRange = [timeString rangeOfString:[formatter PMSymbol]];
		}
		
		if (dataRange.location == NSNotFound)
		{
			dataRange = NSMakeRange(0, [timeString length]);
		}
		else
		{
			dataRange = NSMakeRange(0, dataRange.location);
		}
	}
	
	return self;
}

@end

@interface DistancePieces : NSObject
{
@public
	NSString	*value;
	NSString	*unit;
	NSString	*combined;
}

@end

@implementation DistancePieces

- (id)initWithMeters:(int)meters imperial:(BOOL)imperial
{
	if (self = [super init])
	{
		float	fValue = 0;
		int		iValue = 0;
		
		if (imperial)
		{
			float	feet = meters * 3.28084f;
			
			if (feet <= 500)
			{
				iValue = ceilf(feet);
				unit = @"ft";
			}
			else
			{
				float	miles = feet / 5280.0f;
				
				fValue = miles;
				unit = @"mi";
			}
		}
		else
		{
			if (meters <= 500)
			{
				iValue = (meters > 0) ? meters : 1;
				unit = @"m";
			}
			else
			{
				float	km = meters / 1000.0f;

				fValue = km;
				unit = @"km";
			}
		}
		
		if (fValue)
		{
			static NSNumberFormatter	*formatter = nil;
			
			if (!formatter)
			{
				formatter = [[NSNumberFormatter alloc] init];
				[formatter setMaximumFractionDigits:1];
				[formatter setMinimumIntegerDigits:1];
				[formatter setUsesGroupingSeparator:YES];
				[formatter setGroupingSize:3];
			}
			
			value = [formatter stringFromNumber:[NSNumber numberWithFloat:fValue]];
		}
		else
		{
			value = [NSString stringWithFormat:@"%d", iValue];
		}

		combined = [NSString stringWithFormat:@"%@ %@", value, unit];
	}
	
	return self;
}

@end

@implementation FormatUtils

+ (NSString *)formatTimeRemaining:(int)seconds
{
	TimeRemainingPieces		*pieces = [[[TimeRemainingPieces alloc] initWithSeconds:seconds] autorelease];
	
	return pieces->combinedString;
}

+ (NSString *)formatArrivalTime:(int)seconds
{
	ArrivalTimePieces	*pieces = [[[ArrivalTimePieces alloc] initWithSeconds:seconds] autorelease];
	
	return pieces->timeString;
}

+ (NSString *)formatDistance:(int)meters imperial:(BOOL)imperial
{
	DistancePieces	*pieces = [[[DistancePieces alloc] initWithMeters:meters imperial:imperial] autorelease];
	
	return pieces->combined;
}

+ (NSAttributedString *)formatTimeRemaining:(UILabel *)label seconds:(int)seconds
{
	NSMutableAttributedString	*result = nil;
	UIFont						*boldFont = [UIFont boldSystemFontOfSize:[label.font pointSize]];
	TimeRemainingPieces			*pieces = [[[TimeRemainingPieces alloc] initWithSeconds:seconds] autorelease];
	
	result = [[[NSMutableAttributedString alloc] initWithString:pieces->combinedString] autorelease];
	[result addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [pieces->value length])];
	
	if (pieces->subValue)
	{
		[result addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange([pieces->value length] + 2, [pieces->subValue length])];
	}
	
	return result;
}

+ (NSAttributedString *)formatArrivalTime:(UILabel *)label seconds:(int)seconds
{
	NSMutableAttributedString	*result;
	ArrivalTimePieces			*pieces = [[[ArrivalTimePieces alloc] initWithSeconds:seconds] autorelease];
	
	result = [[[NSMutableAttributedString alloc] initWithString:pieces->timeString] autorelease];
	[result addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[label.font pointSize]] range:pieces->dataRange];

	return result;
}

+ (NSAttributedString *)formatDistance:(UILabel *)label meters:(int)meters imperial:(BOOL)imperial
{
	NSMutableAttributedString	*result = nil;
	DistancePieces				*pieces = [[[DistancePieces alloc] initWithMeters:meters imperial:imperial] autorelease];
	
	result = [[[NSMutableAttributedString alloc] initWithString:pieces->combined] autorelease];
	[result addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:[label.font pointSize]] range:NSMakeRange(0, [pieces->value length])];
	
	return result;
}

@end
