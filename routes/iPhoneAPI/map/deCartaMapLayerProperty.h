//
//  deCartaMapLayerProperty.h
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaGlobals.h"

/*!
 * @internal
 * This class is used only inside API
 */
@interface deCartaMapLayerProperty : NSObject {
	MapLayerType mapLayerType;
	float tileImageSizeFactor;
	NSString * templateSeedTileUrl;
	NSString * configuration;
	NSString * sessionId;
	
	deCartaImageFormatEnum format;
}
@property(nonatomic,assign)MapLayerType mapLayerType;
@property(nonatomic,assign)float tileImageSizeFactor;
@property(nonatomic,retain)NSString * templateSeedTileUrl;
@property(nonatomic,retain)NSString * configuration;
@property(nonatomic,retain)NSString * sessionId;

@property(nonatomic,assign)deCartaImageFormatEnum format;

+(deCartaMapLayerProperty *)getInstance:(MapLayerType) inMapLayerType;

@end
