//
//  TileThread.m
//  iPhoneApp
//
//  Created by Z.S. on 2/1/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaTileThreadPool.h"
#import "deCartaConfig.h"
#import "deCartaTile.h"
#import "deCartaWebServices.h"
#import "deCartaLogger.h"
#import "deCartaUtil.h"

#define LONG_LOAD_TIME_SAVE_TO_DB 0.15

@interface deCartaTileThreadPool(Private)
-(void)addToTileImages:(deCartaTile *)requestTile withImage:(UIImage *)image;

@end
@implementation deCartaTileThreadPool(Private)

-(void)addToTileImages:(deCartaTile *)requestTile withImage:(UIImage *)image{
	@synchronized	(_drawingLock){
		if([_tileImages objectForKey:requestTile]==nil){
			[_tileImages setObject:image forKey:requestTile];
			[_mapView performSelector:@selector(resumeView)];
		}
	
	}
}
																 


@end


@implementation deCartaTileThreadPool
@synthesize tileCache=_tileCache;

-(id)initWithMapView:(id)inMapView
{
	self=[super init];
    if(self){
		_mapView=[inMapView retain];
		_drawingLock=[[_mapView performSelector:@selector(drawingLock)] retain];
		_tileImages=[[_mapView performSelector:@selector(tileImages)] retain];
		_tileTextureRefs=[[_mapView performSelector:@selector(tileTextureRefs)] retain];
		
		_tilesWaitForLoading=[[NSMutableArray alloc] init];
		_requestTiles=[[NSMutableArray alloc] initWithCapacity:g_config.TILE_THREAD_COUNT];
        _obtainTileByDb=[[NSMutableArray alloc] initWithCapacity:g_config.TILE_THREAD_COUNT];
		for(int i=0;i<g_config.TILE_THREAD_COUNT;i++){
			[_requestTiles addObject:[NSNull null]];
            [_obtainTileByDb addObject:[NSNumber numberWithBool:NO]];
		}
		_tilesWaitForLoadingLock=[[NSCondition alloc] init];
		_stop=NO;
		
		_tilesReadingLock=[[NSCondition alloc] init];
        _tileCache=[[deCartaTileCache alloc] initWithMapView:inMapView requestTiles:_requestTiles tilesReadingLock:_tilesReadingLock];
        
        _networkLock=[[NSCondition alloc] init];
        _obtainTileByDbLock=[[NSCondition alloc] init];
	}
	return self;
}

-(void)startAllThreads{
	_stop=NO;
	for (int i = 0; i < g_config.TILE_THREAD_COUNT; i++)
	{
		[NSThread detachNewThreadSelector:@selector(runThread:) toTarget:self withObject:[NSNumber numberWithInt:i]];

	}
	
}

-(void)stopAllThreads{
	_stop=YES;
}

-(void)addRequestTiles:(NSArray *)requestTiles{
	[_tilesWaitForLoadingLock lock];
	[_tilesWaitForLoading removeAllObjects];
	[_tilesWaitForLoading addObjectsFromArray:requestTiles];
	[_tilesWaitForLoadingLock signal];
	[_tilesWaitForLoadingLock unlock];
}

- (void) runThread:(NSNumber *) sequence
{
	
	int seq=[sequence intValue];
    BOOL networkFailed=FALSE;
	
	while (!_stop)
	{
		NSAutoreleasePool *	pool = [[NSAutoreleasePool alloc] init];
		@try {
			if(seq>0 && networkFailed){
                [_networkLock lock];
                //[deCartaLogger info:[NSString stringWithFormat:@"TileThreadPool runThread networkFailed seq:%d wait",seq]];
                [_networkLock wait];
                //[deCartaLogger info:[NSString stringWithFormat:@"TileThreadPool runThread networkFailed seq:%d resume",seq]];
                [_networkLock unlock];
            }
            
            if(seq>0 && [[_obtainTileByDb objectAtIndex:seq] boolValue]){
                [_obtainTileByDbLock lock];
                BOOL allByDb=YES;
                for(int i=0;i<g_config.TILE_THREAD_COUNT;i++){
                    if(![[_obtainTileByDb objectAtIndex:i] boolValue]){
                        allByDb=NO;
                        break;
                    }
                }
                if(allByDb){
                    //[deCartaLogger info:[NSString stringWithFormat:@"TileThreadPool allByDb wait seq:%d",seq]];
                    [_obtainTileByDbLock wait];
                    //[deCartaLogger info:[NSString stringWithFormat:@"TileThreadPool allByDb resume seq:%d",seq]];
                }
                [_obtainTileByDbLock unlock];
            }
			
            deCartaTile * requestTile=nil;
			
			[_tilesWaitForLoadingLock lock];
			if([_tilesWaitForLoading count]<=0){
				[_tilesWaitForLoadingLock wait];
				
			}
			if([_tilesWaitForLoading count]>0){
				requestTile=[[_tilesWaitForLoading objectAtIndex:0] retain];
				[_tilesWaitForLoading removeObjectAtIndex:0];
			}
			[_tilesWaitForLoadingLock unlock];
			
			if(requestTile){
				[requestTile autorelease];
				
				if(![deCartaUtil validateUrl:requestTile]){
					[deCartaLogger debug:[NSString stringWithFormat:@"TileThreadPool runThread invalid tile request:%@",requestTile]];
					continue;
				}
                
                @synchronized(_tilesReadingLock){
                    int threadSeq=-1;
                    for(int i=0;i<g_config.TILE_THREAD_COUNT;i++){
                        deCartaTile * t=[[[_requestTiles objectAtIndex:i] retain] autorelease];
                        if([requestTile isEqual:t]){
                            threadSeq=i;
                            break;
                        }
                    }
                    if(threadSeq!=-1) continue;
                    [_requestTiles replaceObjectAtIndex:seq withObject:requestTile];
                }
				
				@synchronized(_drawingLock)
				{
					if([_tileImages objectForKey:requestTile]!=nil){
						continue;
					}
					if([_tileTextureRefs objectForKey:requestTile]!=nil){
						continue;
					}
					
				}			
				
				UIImage * image=nil;
				image=[_tileCache getTile:requestTile];
                if(image){
					[self addToTileImages:requestTile withImage:image];
					//[deCartaLogger debug:[NSString stringWithFormat:@"TileThreadPool thread %d get image from cache for tile:%@,image size:%d",seq,[requestTile description],[image size]]];
					[_obtainTileByDb replaceObjectAtIndex:seq withObject:[NSNumber numberWithBool:YES]];
                    continue;	
				}
                
                [_obtainTileByDbLock lock];
                [_obtainTileByDb replaceObjectAtIndex:seq withObject:[NSNumber numberWithBool:NO]];
                [_obtainTileByDbLock signal];
                [_obtainTileByDbLock unlock];
                
                @synchronized(_drawingLock){
                    
                }
				
				double webServiceStart=[NSDate timeIntervalSinceReferenceDate]; 
                NSData * imageData=[deCartaWebServices getTileImage:requestTile];
                if(imageData && (image=[UIImage imageWithData:imageData])){
					//[deCartaLogger debug:[NSString stringWithFormat:@"TileThreadPool thread %d get image from network for tile:%@,data length:%d",seq,[requestTile description],[imageData length]]];
					double loadTime=[NSDate timeIntervalSinceReferenceDate]-webServiceStart;
                    //[deCartaLogger debug:[NSString stringWithFormat:@"TileThreadPool thread %d image loading time:%f",seq,loadTime]];
                    [self addToTileImages:requestTile withImage:image];
                    
                    if(g_config.ONLY_CACHE_NETWORK_SLOW){
                        if(loadTime>LONG_LOAD_TIME_SAVE_TO_DB){
                            [_tileCache putTile:requestTile withData:imageData];
                        }
                    }else{
                        [_tileCache putTile:requestTile withData:imageData];
                    }
                    
                    networkFailed=FALSE;
                    [_networkLock lock];
                    [_networkLock signal];
                    [_networkLock unlock];
                    
				}else{
                    networkFailed=TRUE;
                }
				
				
			}
		}
		@catch (NSException * e) {
			[deCartaLogger warn:[NSString stringWithFormat:@"TileThreadPool runThread e.name:%@,e.reason:%@",[e name],[e reason]]];

		}
		@finally {
			[_tilesReadingLock lock];
            [_requestTiles replaceObjectAtIndex:seq withObject:[NSNull null]];
            BOOL empty=TRUE;
            for(int i=0;i<g_config.TILE_THREAD_COUNT;i++){
                if([_requestTiles objectAtIndex:i]!=[NSNull null]){
                    empty=FALSE;
                    break;
                }
            }
            if(empty){
                //[deCartaLogger info:[NSString stringWithFormat:@"TileThreadPool thread:%d, requestTiles empty signal",seq]];
                [_tilesReadingLock signal];
            }
			[_tilesReadingLock unlock];
            
            [pool drain];
		}
		
		

	}
	
}

-(void)clearAllRequestTiles{
	[_tilesWaitForLoadingLock lock];
	[_tilesWaitForLoading removeAllObjects];
	[_tilesWaitForLoadingLock unlock];
}

-(void) dealloc{
	[deCartaLogger debug:@"TileThreadPool dealloc"];
	[self stopAllThreads];
	[_mapView release];
	[_drawingLock release];
	[_tileImages release];
	[_tileTextureRefs release];
	
	[_tileCache release];
	
	[_tilesWaitForLoading release];
	[_requestTiles release];
	[_tilesWaitForLoadingLock release];
    
    [_tilesReadingLock release];
    [_networkLock release];
    
    [_obtainTileByDb release];
    [_obtainTileByDbLock release];
	
	[super dealloc];
}

@end
