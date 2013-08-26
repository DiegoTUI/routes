//
//  deCartaTile.h
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "deCartaXYZ.h"
#import "deCartaMapLayerProperty.h"

/*!
 * @internal
 * This class is used only inside API
 */

@interface deCartaTile : NSObject <NSCopying> {
	deCartaMapLayerProperty * mapLayerProperty;

	deCartaXYZ * xyz;

	int distanceFromCenter;
}

@property(nonatomic,retain, readonly) deCartaXYZ * xyz;

@property(nonatomic,assign) int distanceFromCenter;

@property(nonatomic,retain,readonly) deCartaMapLayerProperty * mapLayerProperty;
-(id)initWithMapLayerProperty:(deCartaMapLayerProperty *)mapLayerProperty;

@end
