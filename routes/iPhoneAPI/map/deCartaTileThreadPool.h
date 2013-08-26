//
//  TileThread.h
//  iPhoneApp
//
//  Created by Z.S. on 2/1/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "deCartaDictionary.h"
#import "deCartaTileCache.h"

/*!
 * @internal
 * An internal class to the deCarta iPhone API which manages one or more process
 * threads which are responsible for the download and management of map tiles.
 * @brief Internal class for process threads for managing map tiles.
 */
@interface deCartaTileThreadPool : NSObject {
	id _mapView;
	NSObject * _drawingLock;
	deCartaDictionary * _tileImages;
	deCartaDictionary * _tileTextureRefs;
	
	NSMutableArray * _tilesWaitForLoading;
	NSMutableArray * _requestTiles;
	NSCondition * _tilesWaitForLoadingLock;
	BOOL _stop;
	
	deCartaTileCache * _tileCache;
    NSCondition * _tilesReadingLock;
    
    NSCondition * _networkLock;
    NSCondition * _obtainTileByDbLock;
    NSMutableArray * _obtainTileByDb;
    
}

@property (nonatomic, readonly) deCartaTileCache *tileCache;

-(id) initWithMapView:(id)mapView;

-(void)startAllThreads;

-(void)stopAllThreads;

-(void)addRequestTiles:(NSArray *)requestTiles;

-(void)clearAllRequestTiles;

@end
