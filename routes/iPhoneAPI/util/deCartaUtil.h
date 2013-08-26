//
//  deCartaUtil.h
//  deCartaLibrary
//
//  Created by Scott Gruby on 10/3/08.
//  Copyright 2008-09 deCarta, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "deCartaXYZ.h"
#import "deCartaXYFloat.h"
#import "deCartaXYDouble.h"
#import "deCartaXYInteger.h"
#import "deCartaTile.h"
#import "deCartaPosition.h"
#import "deCartaTileGridResponse.h"
#import "deCartaBoundingBox.h"

/*!
 * @ingroup Util
 * @class deCartaUtil
 * A internal library of assorted utility functions used within the deCarta 
 * iPhone API.
 * @brief API Utility functions, primarily used internally within the API.
 */
@interface deCartaUtil : NSObject
{

}

/*!
 * Determines the zoom level which will display the entire contents of a
 * specified bounding box.
 * @param boundingBox A deCartaBounding box indicating the geographic
 * boundaries of the region to display on the map.
 * @param displaySize The size of the display in pixels.
 * @return The integer zoom level for the map which will allow the map to
 * display the entire bounded region.
 */
+(int)getZoomLevelToFitBoundingBox:(deCartaBoundingBox *)boundingBox withDisplaySize:(deCartaXYInteger *)displaySize;

/*! Get bouding box of tile
 */
+(deCartaBoundingBox *)getTileBoudingBox:(deCartaTile *)tile;

/*! Get bouding box from array of positions
 */
+(deCartaBoundingBox *)getBoundingBoxFromPositions:(NSArray *)positions;

#pragma mark -
#pragma mark @definition methods only used inside API

/*! @internal For internal API use only. */
+(void)initUtil;

/*! @internal For internal API use only. */
+(double)mercXMod:(double)x atZoom:(int)z;

/*! @internal For internal API use only. */
+(int)indexXMod:(int)x atZoom:(int)z;

// +(int)getNFromTileUrl:(NSString *)tileUrl;
// +(int)getEFromTileUrl:(NSString *)tileUrl;
// +(int)getZFromTileUrl:(NSString *)tileUrl;

/*! @internal For internal API use only. */
+(NSString *)getSessionIdFromTileUrl:(NSString *)tileUrl;

/*! @internal For internal API use only. */
+(NSString *) tileUrlToTransparent:(NSString *) tileUrl;

/*! @internal For internal API use only. */
+(NSString *)getConfigurationFromTileUrl:(NSString *)tileUrl;

/*! @internal For internal API use only. */
+(BOOL)validateUrl:(deCartaTile *)requestTile;

/*! @internal For internal API use only. */
+(NSString *)composeSeedTileUrl:(NSString *)host;

/*! @internal For internal API use only. */
+(NSString *)composeUrl:(deCartaTile *)requestTile;

/*! @internal For internal API use only. */
+(deCartaTileGridResponse *)handlePortrayMapRequest:(deCartaXYDouble *)centerXY atZ:(int)gxZoom;

/*! @internal For internal API use only. */
+(deCartaXYInteger *)mercXYToNE:(deCartaXYDouble *)mercXY;

/*! @internal For internal API use only. */
+(deCartaXYDouble *)posToMercPix:(deCartaPosition *)pos atZoom:(float)gxZoom;

/*! @internal For internal API use only. */
+(deCartaPosition *)mercPixToPos:(deCartaXYDouble *)pix atZoom:(float)gxZoom;

/*! @internal For internal API use only. */
+(double)lat2pix:(double)lat atScale:(double)scale;

/*! @internal For internal API use only. */
+(double)lon2pix:(double)lon atScale:(double)scale;

/*!
 * @internal
 * Compute the radians per pixel at a specified zoom level.
 */
+(double)radsPerPixel:(int) tileSize atZoom:(float)gxZoom;

/*! @internal For internal API use only. */
+(double)metersPerPixel:(int)tileSize atZoom:(float)gxZoom atLat:(double)lat;

/*! @internal For internal API use only. */
+(double)pix2Lon:(double)x atScale:(double)scale;

/*! @internal For internal API use only. */
+(double)pix2lat:(double)y atScale:(double)scale;

/*! @internal For internal API use only. */
+(NSArray *)findOverlapXYZs:(NSArray *)tiles atZ:(int)z;
/*! @internal For internal API use only. */
+(NSArray *)findOverlapXYs:(NSArray *)tiles atZ:(int)z;
//+ (NSArray *) findOverlapTiles:(deCartaXYZ *) xyz atZ: (int) zoomLevel;

/*! @internal For internal API use only. */
+(int)getPower2:(int)x;

/*! @internal For internal API use only. */
+(NSArray *)getTouchTilesAtMerc:(deCartaXYDouble *)mercXY z:(int)z radius:(double)radius;

+ (BOOL)covered:(deCartaXYZ *)xyz byTiles:(NSSet *)xyzs z:(int)z blX:(int)blX blY:(int)blY trX:(int)trX trY:(int)trY;

@end
