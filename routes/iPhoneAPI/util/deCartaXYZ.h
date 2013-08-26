//
//  deCartaXYZ.h
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @ingroup Util
 * @class deCartaXYZ
 * An object containing a 3-integer coordinate (X,Y,Z)
 * @brief X,Y,Z integer coordinate triplet
 */
@interface deCartaXYZ : NSObject <NSCopying> {
	int _x; /**< X coordinate */
	int _y; /**< Y coordinate */
	int _z; /**< Z coordinate */
	
}

/*! X coordinate */
@property(nonatomic,assign) int x;

/*! Y coordinate */
@property(nonatomic,assign) int y;

/*! Z coordinate */
@property(nonatomic,assign) int z;

/*! Initialize the deCartaXYZ object with X,Y,and Z values */
-(id)initWithX:(int)x andY:(int)y andZ:(int)z;
+(id)XYZWithX:(int)x andY:(int)y andZ:(int)z;

@end
