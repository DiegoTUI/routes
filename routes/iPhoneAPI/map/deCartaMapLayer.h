//
//  MapLayer.h
//  iPhoneApp
//
//  Created by Z.S. on 2/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaXYZ.h"
#import "deCartaXYDouble.h"
#import "deCartaXYFloat.h"
#import "deCartaMapLayerProperty.h"

@class deCartaTile;


/*!
 * @internal
 * An internal class used by the deCarta iPhone API to manage map layers.
 */
@interface deCartaMapLayer : NSObject {
	deCartaMapLayerProperty * mapLayerProperty;
	float mainLayerDrawPercent;
	BOOL visible;
	
	deCartaXYZ * centerXYZ;
	deCartaXYDouble * centerXY;
	deCartaXYFloat * centerDelta;
	float zoomLayerDrawPercent;
}
@property(nonatomic,retain) deCartaMapLayerProperty * mapLayerProperty;
@property(nonatomic,assign) float mainLayerDrawPercent;
@property(nonatomic,assign) BOOL visible;
@property(nonatomic,retain) deCartaXYZ * centerXYZ;
@property(nonatomic,retain) deCartaXYDouble * centerXY;
@property(nonatomic,retain) deCartaXYFloat * centerDelta;
@property(nonatomic,assign) float zoomLayerDrawPercent;

-(id)initWithMapLayerProperty:(deCartaMapLayerProperty *)inMapLayerProperty;
-(deCartaTile *) createTile;

@end
