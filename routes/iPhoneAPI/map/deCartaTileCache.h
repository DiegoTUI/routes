//
//  deCartaTileCache.h
//  iPhoneApp
//
//  Created by Z.S. on 2/23/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaConfig.h"
#import "deCartaTile.h"

@class deCartaMapView;
/*!
 * @internal
 * This class is an internal class used inside deCartaTileCache class
 * 
 */
@interface TileData : NSObject {
    deCartaTile * requestTile;
    NSData * data;
}
@property(nonatomic,retain)deCartaTile * requestTile;
@property(nonatomic,retain)NSData * data;
-(id)initWithTile:(deCartaTile *)inTile data:(NSData *)inData;
@end

/*!
 * @internal
 * This class is an internal class used by the deCarta iPhone API to manage
 * the local cache of map tiles.
 * @brief Internal map tile cache manager.
 */
@interface deCartaTileCache : NSObject {
	NSString * _cacheDir;
	NSFileManager *	_defaultManager;
	
    NSCondition * _writingLock;
    BOOL _stopWriting;
    NSMutableArray * _writingList;
    NSObject * _gettingLock;
	
    NSMutableArray * _requestTiles;
	NSCondition * _tilesReadingLock;
    
    deCartaMapView *_mapView;
    
    NSMutableArray * _cacheTileFileNames;
}

@property(nonatomic,assign)BOOL stopWriting;

-(id)initWithMapView:(deCartaMapView *)mapView requestTiles:(NSMutableArray *)requestTiles tilesReadingLock:(NSCondition *)tilesReadingLock;

-(UIImage *)getTile:(deCartaTile *)requestTile;

-(void)putTile:(deCartaTile *)requestTile withData:(NSData *)imageData;

-(void)clearCache;

@end
