//
//  deCartaTileCache.m
//  iPhoneApp
//
//  Created by Z.S. on 2/23/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaTileCache.h"
#import "deCartaLogger.h"
#import "deCartaMapView.h"

#define CACHE_DIRECTORY_NAME @"com.decarta.map"

static const int MAX_WRITING_LIST_SIZE=400;

@implementation TileData
@synthesize requestTile;
@synthesize data;

-(id)initWithTile:(deCartaTile *)inTile data:(NSData *)inData{
    self=[super init];
    if(self){
        self.requestTile=inTile;
        self.data=inData;
    }
    return self;
}
-(void)dealloc{
    [requestTile release];
    [data release];
    [super dealloc];
}
@end

@interface deCartaTileCache (Private)
- (void) removeOldestTiles;
//-(NSString *)getTileFileName:(deCartaTile *)tile;
@end

@implementation deCartaTileCache (Private)

- (void) removeOldestTiles{
    [deCartaLogger debug:@"TileCache removeOldestTiles"];
    //if(g_config.CACHE_SIZE<=0) return;
    if([_cacheDir length]<=0) return;
	
    [_writingLock lock];
    @try {
        int max=MAX(0,g_config.CACHE_SIZE);
        [deCartaLogger info:[NSString stringWithFormat:@"TileCache removeOldestTiles cacheTileFileNames count:%d, CACHE_SIZE:%d",[_cacheTileFileNames count],g_config.CACHE_SIZE]];
        while([_cacheTileFileNames count]>max){
            NSString *	tileStr = [_cacheTileFileNames objectAtIndex:0];
            if([tileStr length]<=0){
                break;
            }
			NSString *	path = [_cacheDir stringByAppendingPathComponent:tileStr];
            //[deCartaLogger debug:[NSString stringWithFormat:@"TileCache removeOldestTiles path:%@",path]];
            
			[_defaultManager removeItemAtPath:path error:nil];
            [_cacheTileFileNames removeObjectAtIndex:0];
        }
    }
    @catch (NSException *exception) {
        [deCartaLogger warn:@"TileCache removeOldestTiles exception"];
    }
    @finally {
        [_writingLock unlock];
    }
    
    [deCartaLogger debug:@"TileCache removeOldestTiles done"];
}

@end

@implementation deCartaTileCache
@synthesize stopWriting=_stopWriting;

-(void)waitOnReading{
    [_tilesReadingLock lock];
    BOOL reading=FALSE;
    for(int i=0;i<g_config.TILE_THREAD_COUNT;i++){
        if([_requestTiles objectAtIndex:i]!=[NSNull null]){
            reading=TRUE;
            break;
        }
    }
    if(reading){
        //[deCartaLogger info:[NSString stringWithString:@"TileCache writeTileThread wait"]];
        [_tilesReadingLock wait];
        //[deCartaLogger info:[NSString stringWithString:@"TileCache writeTileThread resume"]];
    }
    [_tilesReadingLock unlock];
    
    [_mapView.touchingLock lock];
    if(_mapView.touching){
        //[deCartaLogger info:[NSString stringWithString:@"TileCache writeTileThread wait on touching"]];
        [_mapView.touchingLock wait];
        //[deCartaLogger info:[NSString stringWithString:@"TileCache writeTileThread resume on touching"]];
    }
    [_mapView.touchingLock unlock];
    
    [_mapView.movingLock lock];
    if(_mapView.moving){
        //[deCartaLogger info:[NSString stringWithString:@"TileCache writeTileThread wait on moving"]];
        [_mapView.movingLock wait];
        //[deCartaLogger info:[NSString stringWithString:@"TileCache writeTileThread resume on moving"]];
    }
    [_mapView.movingLock unlock];

}

-(void)writeTileThread{
    [deCartaLogger info:@"TileCache writeTileThread start"];
    
    //get current cache tiles
    NSAutoreleasePool *pool1=[[NSAutoreleasePool alloc] init];
    NSError * error=nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_cacheDir error:&error];
    [deCartaLogger info:[NSString stringWithFormat:@"TileCache writeTileThread total tiles now:%d",[filesArray count]]];
    if(error != nil) {
        [deCartaLogger warn:[NSString stringWithFormat:@"TileCache writeTileThread Error: %@", [error localizedDescription]]];
    }
    
    // get creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    for(NSString* file in filesArray) {
        NSString* filePath = [_cacheDir stringByAppendingPathComponent:file];
        NSDictionary* properties = [_defaultManager attributesOfItemAtPath:filePath error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:file, @"path", modDate, @"lastModDate",nil]];                 
        }
    }
    
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:^(id path1, id path2){
        return [[path1 objectForKey:@"lastModDate"] compare:[path2 objectForKey:@"lastModDate"]];
                                        
    }];
    
    _cacheTileFileNames=[[NSMutableArray alloc] initWithCapacity:[sortedFiles count]];
    for(int i=0;i<[sortedFiles count];i++){
        [_cacheTileFileNames addObject:[[sortedFiles objectAtIndex:i] objectForKey:@"path"]];
    }
    [pool1 drain];
    [deCartaLogger info:@"TileCache done with sorting"];
    
    
    //begin loop to write and remove tiles
    TileData * tileFileEntry=nil;
    while(true){
        NSAutoreleasePool *	pool = [[NSAutoreleasePool alloc] init];
        if(_stopWriting){
            [deCartaLogger info:@"TileCache writeTileThread break"];
            [pool drain];
            break;
        }
        
        [self waitOnReading];
        
        [tileFileEntry release];
        tileFileEntry=nil;
        
        [_writingLock lock];
        if([_writingList count]<=0){
            [_writingLock wait];
        }
        if([_writingList count]>0){
            tileFileEntry=[[_writingList objectAtIndex:0] retain];
            [_writingList removeObjectAtIndex:0];
        }
        [_writingLock unlock];
        
        if(_stopWriting){
            [deCartaLogger info:@"TileCache writeTileThread break"];
            [pool drain];
            break;
        }
        
        if(tileFileEntry !=nil){
            @try {
                NSString *fileName=[[tileFileEntry.requestTile description] stringByAppendingFormat:@".%@",g_config.IMAGE_FORMAT];
                NSString *path=[_cacheDir stringByAppendingPathComponent:fileName];
                [tileFileEntry.data writeToFile:path atomically:NO];
                //[deCartaLogger debug:[NSString stringWithFormat:@"TileCache writeTileThread:%@",tileFileEntry.requestTile]];
                
                [_cacheTileFileNames addObject:fileName];
                if([_cacheTileFileNames count]>g_config.CACHE_SIZE){
                    [self waitOnReading];
                    NSString * fileNameDel=[_cacheTileFileNames objectAtIndex:0];
                    NSString *pathDel = [_cacheDir stringByAppendingPathComponent:fileNameDel];
                    //[deCartaLogger debug:[NSString stringWithFormat:@"TileCache removeOldestTiles path:%@",pathDel]];
                    [_defaultManager removeItemAtPath:pathDel error:nil];
                    [_cacheTileFileNames removeObjectAtIndex:0];
                }
            }
            @catch (NSException *exception) {
                [deCartaLogger warn:[NSString stringWithFormat:@"TileCache writeTileThread exception name:%@", [exception name]]];
            }
            
        }
        [pool drain];
    }
    [tileFileEntry release];
    tileFileEntry=nil;
    
}

-(id)initWithMapView:(deCartaMapView *)mapView requestTiles:(NSMutableArray *)requestTiles tilesReadingLock:(NSCondition *)tilesReadingLock
{
	self=[super init];
    if(self){
		_requestTiles=[requestTiles retain];
        _tilesReadingLock=[tilesReadingLock retain];
        
        _mapView=[mapView retain];
        
        _defaultManager = [[NSFileManager defaultManager] retain];
		
		NSArray *	paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *	appSupportDirectory = [paths objectAtIndex:0];
		_cacheDir = [[appSupportDirectory stringByAppendingPathComponent:CACHE_DIRECTORY_NAME] retain];
		
		[deCartaLogger debug:[NSString stringWithFormat:@"TileCache init _cacheDir:%@",_cacheDir]];
		if(g_config.CACHE_SIZE<=0){
			[self clearCache];
			return self;
		}
		
		BOOL isDirectory = NO;
		if (![_defaultManager fileExistsAtPath:_cacheDir isDirectory:&isDirectory] || !isDirectory)
		{
			[deCartaLogger warn:@"TileCache init cacheDir is not a directory"];
            [_defaultManager removeItemAtPath:_cacheDir error:nil];
			[_defaultManager createDirectoryAtPath:_cacheDir withIntermediateDirectories:YES  attributes:nil error:nil];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeOldestTiles) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        {
            _stopWriting=false;
            _writingList=[[NSMutableArray alloc] initWithCapacity:200];
            _writingLock=[[NSCondition alloc] init];
            _gettingLock=[[NSObject alloc] init];
            
            [deCartaLogger debug:@"TileCache init start writeTileThread"]; 
            [NSThread detachNewThreadSelector:@selector(writeTileThread) toTarget:self withObject:nil];
        }
        
	}	
	
	return self;
}

-(UIImage *)getTile:(deCartaTile *)requestTile{
	if(g_config.CACHE_SIZE<=0) return nil;
    NSString * fileName=[[requestTile description] stringByAppendingFormat:@".%@",g_config.IMAGE_FORMAT];
    NSString * path=[_cacheDir stringByAppendingPathComponent:fileName];
    NSData *data=nil;
    @synchronized(_gettingLock){
        data = [NSData dataWithContentsOfFile:path];
    }
    if(data==nil) return nil;
    UIImage * image=[UIImage imageWithData:data];
    if(image) {
        //[deCartaLogger debug:[NSString stringWithFormat:@"TileCache getTile:%@",requestTile]];
        return image;
    }
    else{
        [_defaultManager removeItemAtPath:path error:nil];
        [deCartaLogger warn:[NSString stringWithFormat:@"TileCache getTile wrong image data for tile:%@",[requestTile description]]];
        return nil;
    }

}

-(void)putTile:(deCartaTile *)requestTile withData:(NSData *)imageData{
	if(g_config.CACHE_SIZE<=0)return;
	
	if (imageData == nil) return;
	[_writingLock lock];
    {
		TileData * tileData=[[[TileData alloc] initWithTile:requestTile data:imageData] autorelease];
        [_writingList insertObject:tileData atIndex:0];
        if([_writingList count]>MAX_WRITING_LIST_SIZE){
            [_writingList removeLastObject];
        }
		[_writingLock signal];
        //[deCartaLogger debug:[NSString stringWithFormat:@"TileCache putTile:%@",requestTile]];
    }
    [_writingLock unlock];
	
}


-(void)clearCache
{
	[deCartaLogger debug:@"TileCache clearCache"];
	[_writingLock lock];
    {
		if ([_cacheDir length]>0)
		{
			[_defaultManager removeItemAtPath:_cacheDir error:nil];
            
            if (![_defaultManager fileExistsAtPath:_cacheDir])
            {
                [deCartaLogger debug:@"TileCache clearCache cacheDir doesn't exist after clear"];
                [_defaultManager createDirectoryAtPath:_cacheDir withIntermediateDirectories:YES  attributes:nil error:nil];
            }
            [_cacheTileFileNames removeAllObjects];
			
		}
	}
    [_writingLock unlock];
}

-(void)dealloc{
	[deCartaLogger debug:@"TileCache dealloc"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_cacheDir release];
	[_defaultManager release];
	_stopWriting=true;
    [_writingLock release];
    [_writingList release];
    [_gettingLock release];
    [_tilesReadingLock release];
    [_requestTiles release];
    [_mapView release];
    [_cacheTileFileNames release];
	[super dealloc];
}

@end
