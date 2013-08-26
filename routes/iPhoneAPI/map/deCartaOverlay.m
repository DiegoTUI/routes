//
//  Overlay.m
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaOverlay.h"
#import "deCartaTile.h"
#import "deCartaUtil.h"
#import "deCartaLogger.h"
#import "deCartaGlobals.h"

@interface Cluster : NSObject{
    deCartaXYDouble *refMercXY;
    NSMutableArray *clusterPins;
}
@property(nonatomic,retain) deCartaXYDouble *refMercXY;
@property(nonatomic,retain) NSMutableArray *clusterPins;
-(id)initWithRefMercXY:(deCartaXYDouble *)refMercXY clusterPins:(NSMutableArray *)clusterPins;
+(id)ClusterWithRefMercXY:(deCartaXYDouble *)refMercXY clusterPins:(NSMutableArray *)clusterPins;
@end

@implementation Cluster
@synthesize refMercXY,clusterPins;
-(id)initWithRefMercXY:(deCartaXYDouble *)inRefMercXY clusterPins:(NSMutableArray *)inClusterPins{
    self=[super init];
    if(self){
        self.refMercXY=inRefMercXY;
        self.clusterPins=inClusterPins;
        
    }
    return self;
}
+(id)ClusterWithRefMercXY:(deCartaXYDouble *)inRefMercXY clusterPins:(NSMutableArray *)inClusterPins{
    return [[[Cluster alloc] initWithRefMercXY:inRefMercXY clusterPins:inClusterPins] autorelease];
}
-(void)dealloc{
    [refMercXY release];
    [clusterPins release];
    [super dealloc];
}
@end

@interface ClusterNE : NSObject{
    Cluster *cluster;
    deCartaXYInteger *ne;
}
@property(nonatomic,retain) Cluster *cluster;
@property(nonatomic,retain) deCartaXYInteger *ne;
-(id)initWithCluster:(Cluster *)cluster ne:(deCartaXYInteger *)ne;
+(id)ClusterNEWithCluster:(Cluster *)cluster ne:(deCartaXYInteger *)ne;
@end

@implementation ClusterNE
@synthesize cluster,ne;
-(id)initWithCluster:(Cluster *)inCluster ne:(deCartaXYInteger *)inNe{
    self=[super init];
    if(self){
        self.cluster=inCluster;
        self.ne=inNe;
    }
    return self;
}
+(id)ClusterNEWithCluster:(Cluster *)inCluster ne:(deCartaXYInteger *)inNe{
    return [[[ClusterNE alloc] initWithCluster:inCluster ne:inNe] autorelease];
}

-(void)dealloc{
    [cluster release];
    [ne release];
    [super dealloc];
}

@end

static float GRANULARITY=20/1.5f;
static double MIN_DIST[21];
static double ZOOM_SCALE[21];

@interface deCartaOverlay (Private)
-(void)generalizePinsAtZ:(int)zoomLevel;
- (void)removeFromIndex:(deCartaPin *) pin;
-(void)addToIndex:(deCartaPin *)pin;
-(void)resetPinIdxs;

@end
@implementation deCartaOverlay (Private)

-(BOOL) locatePinInIdx:(deCartaPin *)pin atZ:(int)z tag:(NSString *)tag{
    
    if(_pinIdxs[z]==nil) return YES;
    {
        deCartaXYInteger *ne=[deCartaUtil mercXYToNE:[deCartaXYDouble XYWithX:pin.mercXY.x*ZOOM_SCALE[z] andY:pin.mercXY.y*ZOOM_SCALE[z]]];
        NSDictionary *pinIdx=_pinIdxs[z];
        NSArray *clusters=[pinIdx objectForKey:ne];
        Cluster *cluster=nil;
        for(int i=0;i<[clusters count];i++){
            deCartaXYDouble *refMercXY=[[clusters objectAtIndex:i] refMercXY];
            double dist = (pin.mercXY.x - refMercXY.x)*(pin.mercXY.x - refMercXY.x)+(pin.mercXY.y - refMercXY.y)*(pin.mercXY.y - refMercXY.y);
            if(dist<MIN_DIST[z]){
                cluster=[clusters objectAtIndex:i];
                break;
            }
        }
        
        if(cluster!=nil && [cluster.clusterPins containsObject:pin]){
            [deCartaLogger debug:[NSString stringWithFormat:@"ItemizedOverlay locatePinInIdx %@ pin %@ zoom %d indexed correctly",tag,pin.message,z]];
            return TRUE;
        }else{
            [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay locatePinInIdx %@ pin %@ zoom %d not indexed incorrectly",tag, pin.message,z]];
        }
    }
    
    NSDictionary *pinIdx=_pinIdxs[z];
    NSArray *keys=[[pinIdx keyEnumerator] allObjects];
    BOOL found=false;
    for(int i=0;i<[keys count];i++){
        deCartaXYInteger *ne=[keys objectAtIndex:i];
        NSArray *clusters=[pinIdx objectForKey:ne];
        for(int j=0;j<[clusters count];j++){
            Cluster *cluster=[clusters objectAtIndex:j];
            int idx=[cluster.clusterPins indexOfObject:pin];
            if(idx!=NSNotFound){
                found=true;
                break;
            }
        }
        if(found){
            break;
        }
    }
    if(found){
        [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay locatePinInIdx %@ pin %@ zoom %d found at incorrect location",tag,pin.message,z]];
        return YES;
    }
    return NO;
}

-(void)generalizePinsAtZ:(int)zoomLevel{
	if(_pinIdxs[zoomLevel]!=nil) return;
    
    double scale=ZOOM_SCALE[zoomLevel];
    double minDist=MIN_DIST[zoomLevel];
    NSMutableDictionary *pinIdx=[NSMutableDictionary dictionary];
    NSMutableArray *clusters=[NSMutableArray array];
    
    for (int i = 0; i < [_pins count]; i++) {
        deCartaPin *pin = [_pins objectAtIndex:i];
        if (pin.mercXY==nil) {
            continue;
        }
        
        deCartaXYInteger *ne = [deCartaUtil mercXYToNE:[deCartaXYDouble XYWithX:pin.mercXY.x*scale andY:pin.mercXY.y*scale]];
        BOOL included=false;
        for(int j=0;j<[clusters count];j++){
            if([[[clusters objectAtIndex:j] cluster].clusterPins count]==0){
                [deCartaLogger warn:@"ItemizedOverlay generalizePins cluster empty"];
            }
            
            if(![ne isEqual:[[clusters objectAtIndex:j] ne]]){
                continue;
            }
            
            deCartaXYDouble *refMercXY=[[clusters objectAtIndex:j] cluster].refMercXY;
            double dist = (pin.mercXY.x - refMercXY.x)*(pin.mercXY.x - refMercXY.x)+(pin.mercXY.y - refMercXY.y)*(pin.mercXY.y - refMercXY.y);
            if(dist<minDist){
                [[[clusters objectAtIndex:j] cluster].clusterPins addObject:pin];
                included=true;
                break;
            }
            
        }
        
        if(included) continue;
        
        NSMutableArray *newClusterPins=[NSMutableArray array];
        [newClusterPins addObject:pin];
        deCartaXYDouble *refMercXY=[deCartaXYDouble XYWithX:pin.mercXY.x andY:pin.mercXY.y];
        [clusters addObject:[ClusterNE ClusterNEWithCluster:[Cluster ClusterWithRefMercXY:refMercXY clusterPins:newClusterPins] ne:ne]];
    }
    
    for(int i=0;i<[clusters count];i++){
        if(![pinIdx objectForKey:[[clusters objectAtIndex:i] ne]]){
            [pinIdx setObject:[NSMutableArray array] forKey:[[clusters objectAtIndex:i] ne]];
        }
        [[pinIdx objectForKey:[[clusters objectAtIndex:i] ne]] addObject:[[clusters objectAtIndex:i] cluster]];
    }
    
    [_pinIdxs[zoomLevel] release];
    _pinIdxs[zoomLevel]=[pinIdx retain];
    
}



- (void)removeFromIndex:(deCartaPin *) pin{
    if(pin.mercXY==nil) return;
    deCartaXYInteger *ne20 = [deCartaUtil mercXYToNE:[deCartaXYDouble XYWithX:pin.mercXY.x*ZOOM_SCALE[20] andY:pin.mercXY.y*ZOOM_SCALE[20]]];
    for(int z=0;z<21;z++){
        if(_pinIdxs[z]==nil) continue;
        deCartaXYInteger *ne= [deCartaXYInteger XYWithX:ne20.x>>(20-z) andY:ne20.y>>(20-z)];
        NSMutableArray *clusters=[_pinIdxs[z] objectForKey:ne];
        if(clusters==nil){
            [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay removeFromIndex zoom %d cannot find owner clusters pin:%@", z,pin.message]];
            continue;
        }
        Cluster *cluster=nil;
        for(int i=0;i<[clusters count];i++){
            deCartaXYDouble *refMercXY=[[clusters objectAtIndex:i] refMercXY];
            double dist = (pin.mercXY.x - refMercXY.x)*(pin.mercXY.x - refMercXY.x)+(pin.mercXY.y - refMercXY.y)*(pin.mercXY.y - refMercXY.y);
            if(dist<MIN_DIST[z]){
                cluster=[clusters objectAtIndex:i];
                break;
            }
        }
        
        if(cluster==nil){
            [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay removeFromIndex zoom %d cannot find owner cluster pin:%@",z,pin.message]];
            continue;
        }
        int countBefore=[cluster.clusterPins count];
        [cluster.clusterPins removeObject:pin];
        if(countBefore==[cluster.clusterPins count]){
            [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay removeFromIndex zoom %d owner cluster do not contain pin:%@", z,pin.message]];
            continue;
        }
        
        //[deCartaLogger info:[NSString stringWithFormat:@"ItemizedOverlay removeFromIndex zoom %d pin:%@",z,pin.message]];
        if([cluster.clusterPins count] ==0){
            [clusters removeObject:cluster];
            if([clusters count]==0){
                [_pinIdxs[z] removeObjectForKey:ne];
            }
        }
    }
}

-(void)addToIndex:(deCartaPin *)pin{
    if(pin.mercXY==nil) return;
    deCartaXYInteger * ne20 = [deCartaUtil mercXYToNE:[deCartaXYDouble XYWithX:pin.mercXY.x*ZOOM_SCALE[20] andY:pin.mercXY.y*ZOOM_SCALE[20]]];
    for(int z=0;z<21;z++){
        if(_pinIdxs[z]==nil) continue;
        deCartaXYInteger *ne=[deCartaXYInteger XYWithX:ne20.x>>(20-z) andY:ne20.y>>(20-z)];
        if(![_pinIdxs[z] objectForKey:ne]){
            [_pinIdxs[z] setObject:[NSMutableArray array] forKey:ne];
        }
        NSMutableArray *clusters=[_pinIdxs[z] objectForKey:ne];
        BOOL included=false;
        for(int j=0;j<[clusters count];j++){
            if([[[clusters objectAtIndex:j] clusterPins] count]==0){
                [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay addToIndex zoom %d cluster empty",z]];
            }
            deCartaXYDouble *refMercXY=[[clusters objectAtIndex:j] refMercXY];
            double dist = (pin.mercXY.x - refMercXY.x)*(pin.mercXY.x - refMercXY.x)+(pin.mercXY.y - refMercXY.y)*(pin.mercXY.y - refMercXY.y);
            if(dist<MIN_DIST[z]){
                [[[clusters objectAtIndex:j] clusterPins] addObject:pin];
                included=true;
                break;
            }
            
        }
        
        if(included) continue;
        
        NSMutableArray *newClusterPins=[NSMutableArray array];
        [newClusterPins addObject:pin];
        deCartaXYDouble *refMercXY=[deCartaXYDouble XYWithX:pin.mercXY.x andY:pin.mercXY.y];
        [clusters addObject:[Cluster ClusterWithRefMercXY:refMercXY clusterPins:newClusterPins]];
        
    }
    
}


-(void)resetPinIdxs{
	for(int i=0;i<21;i++){
        [_pinIdxs[i] release];
        _pinIdxs[i]=nil;
    }
    
}
@end

@implementation deCartaOverlay
@synthesize name=_name;
@synthesize clustering=_clustering;
@synthesize clusterTouchEventListener=_clusterTouchEventListener;
@synthesize clusterTextOffset=_clusterTextOffset;
@synthesize clusterTextOffsetRelativeTo=_clusterTextOffsetRelativeTo;
@synthesize clusterBackgroundColor=_clusterBackgroundColor;
@synthesize clusterTextColor=_clusterTextColor;
@synthesize clusterBorderColor=_clusterBorderColor;

+(void)initialize{
    for(int i=0;i<21;i++){
        ZOOM_SCALE[i]=pow(2, i-ZOOM_LEVEL);
        MIN_DIST[i]=(GRANULARITY*GRANULARITY)/(ZOOM_SCALE[i]*ZOOM_SCALE[i]);
    }
}

-(id)initWithName:(NSString *)name{
	if(name==nil || [name characterAtIndex:0]==' ' || [name characterAtIndex:[name length]-1]==' '){
		@throw [NSException exceptionWithName:@"InvalidOverlayName" reason:@"Overlay name can't have space at begin and end" userInfo:nil];
	}
	self=[super init];
    if(self){
		_name=[name retain];
		_pins=[[NSMutableArray alloc] init];
        
        _clustering=false;
        _clusterTouchEventListener=nil;
        _clusterTextOffset=[[deCartaXYInteger alloc] initWithXi:0 andYi:0];
        _clusterTextOffsetRelativeTo=OVERLAY_CLUSTER_TEXT_TOP_LEFT;
        _clusterBackgroundColor=0xffff0000;
        _clusterTextColor=0xffffffff;
        _clusterBorderColor=0xffffffff;
        
        for(int i=0;i<21;i++){
            _pinIdxs[i]=nil;
        }
        
        _idxLock=[[NSObject alloc] init];
	}
	
	return self;
}

-(int)size{
	@synchronized(_idxLock){
        return [_pins count];
    }
}

-(deCartaPin *)getAtIndex:(int)i{
	@synchronized(_idxLock){
        if(i<[_pins count] && i>=0){
            return [_pins objectAtIndex:i];
        }else return nil;
    }
    
}

-(void)addPin:(deCartaPin *)pin{
	@synchronized(_idxLock){
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay addPin:%@, size:%d",pin.message, [_pins count]]];
        [_pins addObject:pin];
        pin.ownerOverlay=self;
        [self addToIndex:pin];
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay addPin end:%@, size:%d",pin.message, [_pins count]]];
    }
    
}

-(void)clear{
	@synchronized(_idxLock){
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay clear size:%d",[_pins count]]];
        [_pins removeAllObjects];
        [self resetPinIdxs];
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay clear end size:%d",[_pins count]]];
    }
   
}

-(deCartaPin *)removeAtIndex:(int)i{
	@synchronized(_idxLock){
        if(i<[_pins count] && i>=0){
            deCartaPin * pin=[[_pins objectAtIndex:i] retain];
            [_pins removeObjectAtIndex:i];
            [self removeFromIndex:pin];
            
            return [pin autorelease];
        }
        return nil;
        
    }
    
}

-(BOOL)removePin:(deCartaPin *)pin{
	@synchronized(_idxLock){
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay removePin:%@, size:%d",pin.message, [_pins count]]];
        int i=[_pins indexOfObject:pin];
        if(i!=NSNotFound){
            [_pins removeObjectAtIndex:i];
            [self removeFromIndex:pin];
            //[deCartaLogger info:[NSString stringWithFormat:@"Overlay removePin:%@ exist, size:%d",pin.message, [_pins count]]];
            return TRUE;
        }
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay removePin:%@ not exist, size%d",pin.message, [_pins count]]];
        return FALSE;
    }
    
}

#pragma mark -
#pragma mark @implementation methods used only in API

-(NSMutableArray *)getVisiblePinsAtZ:(int)z tiles:(NSArray *)tiles{
	NSMutableArray * clusters=[NSMutableArray array];
	
    NSArray * overlapTiles=[deCartaUtil findOverlapXYs:tiles atZ:z];
	
    @synchronized(_idxLock){
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay getVisiblePinsAtZ:%d, size:%d",z,[_pins count]]];
        [self generalizePinsAtZ:z];
        NSDictionary * pinIdx=_pinIdxs[z];
        for(int j=0;j<[overlapTiles count];j++){
            deCartaXYInteger * key=[overlapTiles objectAtIndex:j];
            NSArray *clustersL=[pinIdx objectForKey:key];
            for(int k=0;k<[clustersL count];k++){
                [clusters addObject:[[clustersL objectAtIndex:k] clusterPins]];
            }
                        
        }
        //[deCartaLogger info:[NSString stringWithFormat:@"Overlay getVisiblePinsAtZ:%d, size:%d end",z,[_pins count]]];
    }
	
	return clusters;
}

-(void) changePinPos:(deCartaPin *)pin oldMercXY:(deCartaXYDouble *)oldMercXY{
    @synchronized(_idxLock){
        deCartaXYInteger *ne20 = pin.mercXY==nil?nil:[deCartaUtil mercXYToNE:[deCartaXYDouble XYWithX:pin.mercXY.x*ZOOM_SCALE[20] andY:pin.mercXY.y*ZOOM_SCALE[20]]];
        deCartaXYInteger *oldne20=oldMercXY==nil?nil:[deCartaUtil mercXYToNE:[deCartaXYDouble XYWithX:oldMercXY.x*ZOOM_SCALE[20] andY:oldMercXY.y*ZOOM_SCALE[20]]];
        for(int z=0;z<21;z++){
            if(_pinIdxs[z]==nil) continue;
            
            NSMutableArray *clusters=nil;
            Cluster *cluster=nil;
            deCartaXYInteger *ne=ne20==nil?nil:[deCartaXYInteger XYWithX:ne20.x>>(20-z) andY:ne20.y>>(20-z)];
            NSMutableArray *oldClusters=nil;
            Cluster *oldCluster=nil;
            deCartaXYInteger *oldne=oldne20==nil?nil:[deCartaXYInteger XYWithX:oldne20.x>>(20-z) andY:oldne20.y>>(20-z)];
            
            if(oldMercXY!=nil){
                oldClusters=[_pinIdxs[z] objectForKey:oldne];
                if(oldClusters==nil){
                   [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay changePinPos zoom %d oldClusters null",z]]; 
                }
                for(int j=0;j<[oldClusters count];j++){
                    if([[[oldClusters objectAtIndex:j] clusterPins] count]==0){
                        [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay changePinPos zoom %d oldClusters cluster empty",z]];
                        continue;
                    }
                    deCartaXYDouble *refMercXY=[[oldClusters objectAtIndex:j] refMercXY];
                    double dist = (oldMercXY.x - refMercXY.x)*(oldMercXY.x - refMercXY.x)+(oldMercXY.y - refMercXY.y)*(oldMercXY.y - refMercXY.y);
                    if(dist<MIN_DIST[z]){
                        oldCluster=[oldClusters objectAtIndex:j];
                        break;
                    }
                    
                }
                if(oldCluster==nil){
                    [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay changePinPos zoom %d oldCluster null",z]];
                }
            }
            
            if(pin.mercXY!=nil){
                if(![_pinIdxs[z] objectForKey:ne]){
                    [_pinIdxs[z] setObject:[NSMutableArray array] forKey:ne];
                }
                clusters=[_pinIdxs[z] objectForKey:ne];
                BOOL included=false;
                for(int j=0;j<[clusters count];j++){
                    if([[[clusters objectAtIndex:j] clusterPins] count]==0){
                        [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay changePinPos zoom %d cluster empty",z]];
                    }
                    deCartaXYDouble *refMercXY=[[clusters objectAtIndex:j] refMercXY];
                    double dist = (pin.mercXY.x - refMercXY.x)*(pin.mercXY.x - refMercXY.x)+(pin.mercXY.y - refMercXY.y)*(pin.mercXY.y - refMercXY.y);
                    if(dist<MIN_DIST[z]){
                        cluster=[clusters objectAtIndex:j];
                        if(cluster!=oldCluster){
                            [cluster.clusterPins addObject:pin];
                        }
                        included=true;
                        break;
                    }
                    
                }
                
                if(included) continue;
                NSMutableArray * newClusterPins=[NSMutableArray array];
                [newClusterPins addObject:pin];
                deCartaXYDouble *refMercXY=[deCartaXYDouble XYWithX:pin.mercXY.x andY:pin.mercXY.y];
                cluster=[Cluster ClusterWithRefMercXY:refMercXY clusterPins:newClusterPins];
                [clusters addObject:cluster];
                
            }
            
            if(oldCluster!=nil && oldCluster!=cluster){
                int countBefore=[oldCluster.clusterPins count];
                [oldCluster.clusterPins removeObject:pin];
                if(countBefore==[oldCluster.clusterPins count]){
                    [deCartaLogger warn:[NSString stringWithFormat:@"ItemizedOverlay changePinPos zoom %d oldCluster do not contain pin",z]];
                    continue;
                }
                if([oldCluster.clusterPins count]==0){
                    [oldClusters removeObject:oldCluster];
                    if([oldClusters count]==0){
                        [_pinIdxs[z] removeObjectForKey:oldne];
                    }
                }
                
            }
        }
    }
}

		


-(void)dealloc{
	[_name release];
	[_pins release];
	[self resetPinIdxs];
    [_clusterTextOffset release];
    [_clusterTouchEventListener release];
    
    [_idxLock release];
	[super dealloc];
}
		
@end
