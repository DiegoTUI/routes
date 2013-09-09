//
//  FormatUtils.h
//  GeoStarter
//
//  Created by Daniel Posluns on 5/16/13.
//  Copyright (c) 2013 deCarta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormatUtils : NSObject

+ (NSString *)formatTimeRemaining:(int)seconds;
+ (NSString *)formatArrivalTime:(int)seconds;
+ (NSString *)formatDistance:(int)meters imperial:(BOOL)imperial;

+ (NSAttributedString *)formatTimeRemaining:(UILabel *)label seconds:(int)seconds;
+ (NSAttributedString *)formatArrivalTime:(UILabel *)label seconds:(int)seconds;
+ (NSAttributedString *)formatDistance:(UILabel *)label meters:(int)meters imperial:(BOOL)imperial;

@end
