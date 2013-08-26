//
//  TileGridResponse.h
//  iPhoneApp
//
//  Created by Z.S. on 2/4/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "deCartaLength.h"
#import "deCartaPosition.h"
#import "deCartaXYFloat.h"
#import "deCartaXYZ.h"
#import "deCartaXYDouble.h"

/*!
 * @internal
 * An internal class used by the deCarta iPhone API to manage the map tile grid.
 * @brief Internal Map Tile Grid management class.
 */
@interface deCartaTileGridResponse : NSObject {
	deCartaLength * radiusY;
	deCartaPosition * centerPosition;
	deCartaPosition * tileGridCenterPosition;
	deCartaXYFloat * fixedGridPixelOffset;
	NSString * seedTileUrl;
	
	deCartaXYZ * centerXYZ;
	deCartaXYDouble * centerXY;
}
@property(nonatomic,retain) deCartaLength * radiusY;
@property(nonatomic,retain) deCartaPosition * centerPosition;
@property(nonatomic,retain) deCartaPosition * tileGridCenterPosition;
@property(nonatomic,retain) deCartaXYFloat * fixedGridPixelOffset;
@property(nonatomic,retain) NSString * seedTileUrl;
@property(nonatomic,retain) deCartaXYZ * centerXYZ;
@property(nonatomic,retain) deCartaXYDouble * centerXY;

@end
