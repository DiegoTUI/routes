//
//  deCartaUtil.m
//  deCartaLibrary
//
//  Created by Scott Gruby on 10/3/08.
//  Copyright 2008-09 deCarta, Inc. All rights reserved.
//


#import <math.h>
#import "deCartaUtil.h"

#import "deCartaConfig.h"
#import "deCartaLength.h"
#import "deCartaLogger.h"
#import "deCartaGlobals.h"


static NSString * llmaxList[]={
	@"0.000345636472797214,0.000343322753906250",
	@"0.000691272945568983,0.000686645507812500",
	@"0.001382546303032519,0.001373291015625000",
	@"0.002765092605263539,0.002746582031250000",
	@"0.005530185203987857,0.005493164062500000",
	@"0.011060370355776452,0.010986328125000000",
	@"0.022120740293895182,0.021972656250000000",
	@"0.044241477246363230,0.043945312500000000",
	@"0.088482927761462040,0.087890625000000000",
	@"0.176965641673330230,0.175781250000000000",
	@"0.353929573271679340,0.351562500000000000",
	@"0.707845460801532700,0.703125000000000000",
	@"1.415581451872543800,1.406250000000000000",
	@"2.830287664051185000,2.812500000000000000",
	@"5.653589942659626000,5.625000000000000000",
	@"11.251819676168665000,11.250000000000000000",
	@"22.076741328793200000,22.500000000000000000",
	@"41.170427238429790000,45.000000000000000000",
	@"66.653475896509040000,90.000000000000000000",
	@"85.084059050110410000,180.000000000000000000",
	@"89.787438015348100000,360.000000000000000000"
};
static double EARTH_RADIUS_METERS = 6371000.000000;


@interface deCartaUtil (Private)
+(double)mercatorUnproject:(double)t;
+(double)findRadPhi:(double)phi t:(double)t;

@end

@implementation deCartaUtil (Private)
+(double)mercatorUnproject:(double)t{
	return (M_PI/2) - 2 * atan(t);
}


+(double)findRadPhi:(double)phi t:(double)t{
	double ecc = 0.08181919084262157;
	double eSinPhi = ecc * sin(phi);
	double precalculate = t * pow(((1 - eSinPhi) / (1 + eSinPhi)), (ecc / 2));
	return (M_PI / 2) - (2 * (atan(precalculate)));	
}	
@end


@implementation deCartaUtil
#pragma mark - @implementation public methods

+(int)getZoomLevelToFitBoundingBox:(deCartaBoundingBox *)boundingBox withDisplaySize:(deCartaXYInteger *)displaySize{
	int screenX = displaySize.x/2;
	int screenY = displaySize.y/2;
	int fitZoom = g_config.ZOOM_LOWER_BOUND;
	for (int gxZoom = g_config.ZOOM_UPPER_BOUND; gxZoom >= g_config.ZOOM_LOWER_BOUND; --gxZoom) {
		
		double scale = [deCartaUtil radsPerPixel:g_config.TILE_SIZE atZoom:gxZoom];
		
		double pixelsY = [deCartaUtil lat2pix:[boundingBox getCenterPosition].lat atScale:scale];
		double pixelsX = [deCartaUtil lon2pix:[boundingBox getCenterPosition].lon atScale:scale];
		
		double maxlat = [deCartaUtil pix2lat:(int)pixelsY+screenY atScale:scale];
		double maxlon = [deCartaUtil pix2Lon:(int)pixelsX+screenX atScale:scale];
		
		double minlat = [deCartaUtil pix2lat:(int)pixelsY-screenY atScale:scale];
		double minlon = [deCartaUtil pix2Lon:(int)pixelsX-screenX atScale:scale];
		
		deCartaBoundingBox * gxbbox=[[[deCartaBoundingBox alloc] initWithMin:
									  [deCartaPosition positionWithLat:minlat andLon:minlon] andMax:
									  [deCartaPosition positionWithLat:maxlat andLon:maxlon]] autorelease];
		if([gxbbox contains:boundingBox.minPosition] && [gxbbox contains:boundingBox.maxPosition]){
			fitZoom=gxZoom;
			break;
		}
		
	}
	return fitZoom;
}

+(deCartaBoundingBox *)getTileBoudingBox:(deCartaTile *)tile{
    double mercX=tile.xyz.x*g_config.TILE_SIZE;
    double mercY=tile.xyz.y*g_config.TILE_SIZE;
    deCartaPosition * minPos=[deCartaUtil mercPixToPos:[deCartaXYDouble XYWithX:mercX andY:mercY] atZoom:tile.xyz.z];
    mercX+=g_config.TILE_SIZE;
    mercY+=g_config.TILE_SIZE;
    deCartaPosition * maxPos=[deCartaUtil mercPixToPos:[deCartaXYDouble XYWithX:mercX andY:mercY] atZoom:tile.xyz.z];
    return [[[deCartaBoundingBox alloc] initWithMin:minPos andMax:maxPos] autorelease];
}

+(deCartaBoundingBox *)getBoundingBoxFromPositions:(NSArray *)positions{
    double minX=180.0;
    double minY=90.0;
    double maxX=-180.0;
    double maxY=-90.0;
    
    for(int i=0;i<[positions count];i++){
        deCartaPosition * pos=[positions objectAtIndex:i];
        if(pos.lon<minX) minX=pos.lon;
        if(pos.lat<minY) minY=pos.lat;
        if(pos.lon>maxX) maxX=pos.lon;
        if(pos.lat>maxY) maxY=pos.lat;
    }
    
    return [[[deCartaBoundingBox alloc] initWithMin:[deCartaPosition positionWithLat:minY andLon:minX] andMax:[deCartaPosition positionWithLat:maxY andLon:maxX]] autorelease];
}


#pragma mark -
#pragma mark @implementation methods only used inside API

+(void)initUtil{
	int tileSize=g_config.TILE_SIZE;
	for (int i=0; i<21; i++) {
		MERC_X_MODS[i]=tileSize<<i;
		INDEX_X_MODS[i]=1<<i;
		//[deCartaLogger debug:[NSString stringWithFormat:@"Util zoom,mercX,indexX:%d,%d,%d",i,MERC_X_MODS[i],INDEX_X_MODS[i]]];
	}
	
}

+(double)mercXMod:(double)x atZoom:(int)z{
	long mod=MERC_X_MODS[z];
	long mod2=mod/2;
	if(x<mod2 && x>=-mod2) return x;
	return (((long)x+mod2)%mod+mod)%mod-mod2+(x-(long)x);
}

+(int)indexXMod:(int)x atZoom:(int)z{
	int mod=INDEX_X_MODS[z];
	int mod2=mod/2;
	if(x<mod2 && x>=-mod2) return x;
	return ((x+mod2)%mod+mod)%mod-mod2;
}

/*
+(int)getNFromTileUrl:(NSString *)tileUrl{
	
	NSRange range1=[tileUrl rangeOfString:@"&N="];
	int index1=range1.location+range1.length;
	NSRange range2=[tileUrl rangeOfString:@"&" options:0 range:NSMakeRange(index1, [tileUrl length]-index1)];
	NSString * nStr= [tileUrl substringWithRange:NSMakeRange(index1, range2.location-index1)];
	return [nStr intValue];
}

+(int)getEFromTileUrl:(NSString *)tileUrl{
	NSRange range1=[tileUrl rangeOfString:@"&E="];
	int index1=range1.location+range1.length;
	return [[tileUrl substringFromIndex:index1] intValue];
}

+(int)getZFromTileUrl:(NSString *)tileUrl{
	NSRange range1=[tileUrl rangeOfString:@"LLMAX="];
	int index1=range1.location+range1.length;
	NSRange range2=[tileUrl rangeOfString:@"&" options:0 range:NSMakeRange(index1, [tileUrl length]-index1)];
	NSString * llmax=[tileUrl substringWithRange:NSMakeRange(index1, range2.location-index1)];
	for(int i=0;i<21;i++){
		if([llmaxList[i] compare:llmax]==NSOrderedSame){
			return 20-i;
		}
	}
	return -1;
}*/

+(NSString *)getSessionIdFromTileUrl:(NSString *)tileUrl{
	NSRange range1=[tileUrl rangeOfString:@"SESSIONID="];
	int first=range1.location;
	if(first==NSNotFound) return @"";
	int start=first+range1.length;
	int end=[tileUrl rangeOfString:@"&"	options:0 range:NSMakeRange(start, [tileUrl length]-start)].location;
	return [tileUrl substringWithRange:NSMakeRange(start, end-start)];
	
}

+(NSString *) tileUrlToTransparent:(NSString *) tileUrl{
	NSRange first=[tileUrl rangeOfString:@"CONFIG="];
	if(first.location==NSNotFound) return @"";
	int start=first.location+first.length;
	
	
	NSMutableString * sb=[NSMutableString string];
	[sb appendString:[tileUrl substringToIndex:start]];
	[sb appendString:g_config.transparentConfiguration];
	NSRange end=[tileUrl rangeOfString:@"&" options:0 range:NSMakeRange(start, [tileUrl length]-start)];
	[sb appendString:[tileUrl substringFromIndex:end.location]];
	return sb;
	
	
}

+(NSString *)getConfigurationFromTileUrl:(NSString *)tileUrl{
	NSRange range1=[tileUrl rangeOfString:@"CONFIG="];
	if(range1.location==NSNotFound) return @"";
	
	int start1=range1.location+range1.length;
	NSRange range2=[tileUrl rangeOfString:@"&" options:0 range:NSMakeRange(start1, [tileUrl length]-start1)];
	return [tileUrl substringWithRange:NSMakeRange(start1, range2.location-start1)];
}

+(BOOL)validateUrl:(deCartaTile *)requestTile{
	if([requestTile.mapLayerProperty.templateSeedTileUrl length]<=0){
		return false;
	}
	if(requestTile.mapLayerProperty.mapLayerType == SATELLITE){
		NSString * ll=llmaxList[21 - 1 - requestTile.xyz.z];
		NSArray * lls=[ll componentsSeparatedByString:@","];
					   
		NSString * lonS=[lls objectAtIndex:1];
		double lon=[lonS doubleValue];
		int y=requestTile.xyz.y;
		if((y>0 && (y+1-0.5)*lon>180) || (y<0 && (y+0.5)*lon<-180)){
			return false;
		}
	}
	return true;
}

+(NSString *)composeSeedTileUrl:(NSString *)host{
	NSRange range1=[host rangeOfString:@"/openls/openls"];
	NSMutableString * seedTileUrl=[NSMutableString stringWithString:[host substringToIndex:range1.location]];
	[seedTileUrl appendString:g_config.TILE_URL_SUFFIX];
    [seedTileUrl appendString:@"?LLMIN=0.0,0.0&LLMAX=41.170427238429790000,45.000000000000000000&CACHEABLE=true&WIDTH="];
	[seedTileUrl appendFormat:@"%d",g_config.TILE_SIZE];
	[seedTileUrl appendString:@"&HEIGHT="];
	[seedTileUrl appendFormat:@"%d",g_config.TILE_SIZE];
	[seedTileUrl appendString:@"&CLIENTNAME="];
	[seedTileUrl appendString:g_config.clientName];
	[seedTileUrl appendString:@"&SESSIONID="];
	[seedTileUrl appendFormat:@"%d",g_config.STATELESS_SESSION_ID];
	[seedTileUrl appendString:@"&FORMAT="];
	[seedTileUrl appendString:g_config.IMAGE_FORMAT];
	[seedTileUrl appendString:@"&CONFIG="];
	NSString * configuration=(g_scale>1)?g_config.configuration_high_res:g_config.configuration_default;
	[seedTileUrl appendString:configuration];
	[seedTileUrl appendString:@"&N=0&E=-3"];
	return seedTileUrl;
	
}

+(NSString *)composeUrl:(deCartaTile *)requestTile{
	NSMutableString * url=[NSMutableString string];
	NSString * seedTileUrl=[requestTile mapLayerProperty].templateSeedTileUrl;
	if(requestTile.mapLayerProperty.mapLayerType==SATELLITE){
		NSRange range1 = [seedTileUrl rangeOfString:@"&LL="];
		int index1=range1.location+range1.length;
		[url appendString:[seedTileUrl substringToIndex:index1]];
		NSArray * lls=[llmaxList[21-1-requestTile.xyz.z] componentsSeparatedByString:@","];
		[url appendFormat:@"%f,%f&ZOOM=%d",[[lls objectAtIndex:0] doubleValue]/2,[[lls objectAtIndex:1] doubleValue]/2,requestTile.xyz.z];
		range1=[seedTileUrl rangeOfString:@"&ZOOM="];
		index1=range1.location+range1.length;
		NSRange range2=[seedTileUrl rangeOfString:@"&" options:0 range:NSMakeRange(index1, [seedTileUrl length]-index1)];
		int index2=range2.location;
		
		NSRange range3=[seedTileUrl rangeOfString:@"&N="];
		int index3=range3.location+range3.length;
		[url appendString:[seedTileUrl substringWithRange:NSMakeRange(index2, index3-index2)]];
		[url appendFormat:@"%d&E=",requestTile.xyz.y];
		double lon=[[lls objectAtIndex:1] doubleValue];
		int mod=round(360/lon);
		int x=requestTile.xyz.x;
		if(x<0 && (x+0.5)*lon<-180){
			x%=mod;
			x+=mod;
		}
		[url appendFormat:@"%d",x];
		 
	
	}else {
		NSRange range1=[seedTileUrl rangeOfString:@"&LLMAX="];
		int index1=range1.location+range1.length;
		NSRange range2=[seedTileUrl rangeOfString:@"&" options:0 range:NSMakeRange(index1,[seedTileUrl length]-index1)];
		int index2=range2.location;
		url=[NSMutableString stringWithString:[seedTileUrl substringWithRange:NSMakeRange(0,index1)]];
		[url appendString:llmaxList[21-1-requestTile.xyz.z]];
		
		NSRange range3=[seedTileUrl rangeOfString:@"&N="];
		int index3=range3.location+range3.length;
		[url appendString:[seedTileUrl substringWithRange:NSMakeRange(index2, index3-index2)]];
		[url appendFormat:@"%d",requestTile.xyz.y];
		[url appendString:@"&E="];
		[url appendFormat:@"%d",requestTile.xyz.x];
	}
	
	return url;
																			   
}

+(deCartaTileGridResponse *)handlePortrayMapRequest:(deCartaXYDouble *)centerXY atZ:(int)gxZoom{
	deCartaTileGridResponse * resp=[[[deCartaTileGridResponse alloc] init] autorelease];
	long pixX=round(centerXY.x);
	long pixY=round(centerXY.y);
	
	if(pixY>=(0x7fffffff) || pixY<-(0x7fffffff)){
		
		@throw [NSException exceptionWithName:@"MERCATOR_Y_INFINITY" reason:@"Mercator y infinite" userInfo:nil];
	}
	
	int tileSize=g_config.TILE_SIZE;
	float offsetPixX = (tileSize + ((int)pixX % tileSize)) % tileSize - tileSize / 2;
	float offsetPixY = (tileSize + ((int)pixY % tileSize)) % tileSize - tileSize / 2;
	int fixedSeedColumnIdx = (int) floor((double) pixX / tileSize);
	int fixedSeedRowIdx = (int) floor((double) pixY / tileSize);
	resp.fixedGridPixelOffset=[[[deCartaXYFloat alloc] initWithXf:-offsetPixX andYf:offsetPixY] autorelease];
	resp.centerXYZ = [[[deCartaXYZ alloc] initWithX:fixedSeedColumnIdx andY:fixedSeedRowIdx andZ:gxZoom] autorelease];
	resp.centerXY= [[[deCartaXYDouble alloc] initWithXd:centerXY.x andYd:centerXY.y] autorelease];
	
	double scale = [deCartaUtil radsPerPixel:tileSize atZoom:gxZoom];
	double radius = tileSize / 2 * scale * EARTH_RADIUS_METERS;
	double lat=[deCartaUtil pix2lat:centerXY.y atScale:scale];
	radius *= cos(lat * M_PI / 180);
		
	resp.radiusY=[[[deCartaLength alloc] initWithDistance:radius andUOM:M] autorelease];
	return resp;
}

+(deCartaXYInteger *)mercXYToNE:(deCartaXYDouble *)mercXY{
	int tileSize=g_config.TILE_SIZE;
	int e = (int) floor(mercXY.x / tileSize);
	int n = (int) floor(mercXY.y / tileSize);
	return [[[deCartaXYInteger alloc] initWithXi:e andYi:n] autorelease];
	
}

+(deCartaXYDouble *)posToMercPix:(deCartaPosition *)pos atZoom:(float)gxZoom{
	int tileSize=g_config.TILE_SIZE;
	double scale = [deCartaUtil radsPerPixel:tileSize atZoom:gxZoom];
	
	double y = [deCartaUtil lat2pix:pos.lat atScale:scale];
	double x = [deCartaUtil lon2pix:pos.lon atScale:scale];
	return [[[deCartaXYDouble alloc] initWithXd:x andYd:y] autorelease];
}

+(deCartaPosition *)mercPixToPos:(deCartaXYDouble *)pix atZoom:(float)gxZoom{
	int tileSize=g_config.TILE_SIZE;
	double scale = [deCartaUtil radsPerPixel:tileSize atZoom:gxZoom];
	double lat=[deCartaUtil pix2lat:pix.y atScale:scale];
	double lon=[deCartaUtil pix2Lon:pix.x atScale:scale];
	return [[[deCartaPosition alloc] initWithLat:lat andLon:lon] autorelease];
	
}

+(double)lat2pix:(double)lat atScale:(double)scale{
	if(lat==90 || lat==-90) {
		@throw [NSException exceptionWithName:@"INVALID_LATITUDE_90" reason:[NSString stringWithFormat:@"Latitude is %f",lat] userInfo:0];
	}
	
	double radLat = (lat * M_PI) / 180;
	double ecc = 0.08181919084262157;
	double sinPhi = sin(radLat);
	double eSinPhi = ecc * sinPhi;
	double retVal = log(((1.0 + sinPhi) / (1.0 - sinPhi)) * pow((1.0 - eSinPhi) / (1.0 + eSinPhi), ecc)) / 2.0;
	
	double r=retVal/scale;
	if(retVal == DBL_MAX || retVal == -DBL_MAX || r==DBL_MAX || r==-DBL_MAX){
		@throw [NSException exceptionWithName:@"MERCATOR_Y_INFINITY" reason:@"Mercator y infinite" userInfo:nil];
	}
	return r;
}

+(double)lon2pix:(double)lon atScale:(double)scale{
	return (double)(((lon / 180) * M_PI) / scale);
}

+(double)radsPerPixel:(int) tileSize atZoom:(float)gxZoom{
	return 2 * M_PI / (tileSize*pow(2,gxZoom));
}

+(double)metersPerPixel:(int)tileSize atZoom:(float)gxZoom atLat:(double)lat{
	double radsPerPixel = [deCartaUtil radsPerPixel:tileSize atZoom:gxZoom];
	return radsPerPixel * EARTH_RADIUS_METERS * cos(lat * M_PI / 180);
}

+(double)pix2Lon:(double)x atScale:(double)scale{
	return (x * scale) * 180 / M_PI;
}

+(double)pix2lat:(double)y atScale:(double)scale	
{
	double phiEpsilon = 1E-7;
	double phiMaxIter = 12;

	static double E = 2.718281828459045;
	double t = pow(E, (-y * scale));
	double prevPhi = [deCartaUtil mercatorUnproject:t];
	double newPhi = [deCartaUtil findRadPhi:prevPhi t:t];
	double iterCount = 0;
	while (iterCount < phiMaxIter &&
		   ABS(prevPhi - newPhi) > phiEpsilon) {
		prevPhi = newPhi;
		newPhi = [deCartaUtil findRadPhi:prevPhi t:t];
		iterCount++;
	}
	return newPhi * 180 / M_PI;
}



+(NSArray *)findOverlapXYZs:(NSArray *)tiles atZ:(int)z{
	if([tiles count]<=0) return nil;
	
	deCartaXYZ * xyz0=((deCartaTile *)[tiles objectAtIndex:0]).xyz;
	
	NSMutableArray * ols=[NSMutableArray array];
	
	if(z<xyz0.z){
		float scale=1.0f/(1<<(xyz0.z-z));
		
		for(int i=0;i<[tiles count];i++){
			deCartaXYZ * xyz=((deCartaTile *)[tiles objectAtIndex:i]).xyz;
			deCartaXYZ * xyzL=[[[deCartaXYZ alloc] initWithX:(int)floorf(xyz.x*scale) andY:(int)floorf(xyz.y*scale) andZ:z] autorelease];
			if(![ols containsObject:xyzL]) [ols addObject:xyzL];
		}
	}
	else if(z==xyz0.z){
		for(int i=0;i<[tiles count];i++){
			deCartaXYZ * xyz=((deCartaTile *)[tiles objectAtIndex:i]).xyz;
			if(![ols containsObject:xyz]) [ols addObject:xyz];
		}
	}
	else{
		int expand=1<<(z-xyz0.z);
		NSMutableArray * parsed=[NSMutableArray array];
		
		for(int i=0;i<[tiles count];i++){
			deCartaXYZ * xyz=((deCartaTile *)[tiles objectAtIndex:i]).xyz;
			if([parsed containsObject:xyz]) continue;
			[parsed addObject:xyz];
			for(int x=xyz.x*expand;x<(xyz.x+1)*expand;x++){
				for(int y=xyz.y*expand;y<(xyz.y+1)*expand;y++){
					[ols addObject:[[[deCartaXYZ alloc] initWithX:x andY:y andZ:z] autorelease]];
				}
			}
		}
	}
	
	return ols;
		
}

+(NSArray *)findOverlapXYs:(NSArray *)tiles atZ:(int)z{
	if([tiles count]<=0) return nil;
	
	deCartaXYZ * xyz0=((deCartaTile *)[tiles objectAtIndex:0]).xyz;
	
	NSMutableArray * ols=[NSMutableArray array];
	
	if(z<xyz0.z){
		float scale=1.0f/(1<<(xyz0.z-z));
		
		for(int i=0;i<[tiles count];i++){
			deCartaXYZ * xyz=((deCartaTile *)[tiles objectAtIndex:i]).xyz;
			deCartaXYInteger * xyL=[deCartaXYInteger XYWithX:(int)floorf(xyz.x*scale) andY:(int)floorf(xyz.y*scale)];
			if(![ols containsObject:xyL]) [ols addObject:xyL];
		}
	}
	else if(z==xyz0.z){
		for(int i=0;i<[tiles count];i++){
			deCartaXYZ * xyz=((deCartaTile *)[tiles objectAtIndex:i]).xyz;
            deCartaXYInteger *xyL=[deCartaXYInteger XYWithX:xyz.x andY:xyz.y];
			if(![ols containsObject:xyL]) [ols addObject:xyL];
		}
	}
	else{
		int expand=1<<(z-xyz0.z);
		NSMutableArray * parsed=[NSMutableArray array];
		
		for(int i=0;i<[tiles count];i++){
			deCartaXYZ * xyz=((deCartaTile *)[tiles objectAtIndex:i]).xyz;
			if([parsed containsObject:xyz]) continue;
			[parsed addObject:xyz];
			for(int x=xyz.x*expand;x<(xyz.x+1)*expand;x++){
				for(int y=xyz.y*expand;y<(xyz.y+1)*expand;y++){
					[ols addObject:[deCartaXYInteger XYWithX:x andY:y]];
				}
			}
		}
	}
	
	return ols;
    
}


/*
+ (NSArray *) findOverlapTiles:(deCartaXYZ *) xyz atZ: (int) zoomLevel{
	NSMutableArray * xyzs=[NSMutableArray array];
	if(zoomLevel<xyz.z){
		float scale=1.0f/(1<<(xyz.z-zoomLevel));
		deCartaXYZ * xyzL=[[[deCartaXYZ alloc] initWithX:(int)floorf(xyz.x*scale) andY:(int)floorf(xyz.y*scale) andZ:zoomLevel] autorelease];
		[xyzs addObject:xyzL];
	}else{
		int expand=1<<(zoomLevel-xyz.z);
		for(int x=xyz.x*expand;x<(xyz.x+1)*expand;x++){
			for(int y=xyz.y*expand;y<(xyz.y+1)*expand;y++){
				[xyzs addObject:[[[deCartaXYZ alloc] initWithX:x andY:y andZ:zoomLevel] autorelease]];
			}
		}
	}
	return xyzs;
	
}*/

+(int)getPower2:(int)x{
	int power2=1;
	while(power2<x){
		power2=power2<<1;
	}
	return power2;
}



+(NSArray *)getTouchTilesAtMerc:(deCartaXYDouble *)mercXY z:(int)z radius:(double)radius{
	NSMutableArray * tiles=[NSMutableArray array];
	
	int er=(int)floor((mercXY.x+radius)/g_config.TILE_SIZE);
	int el=(int)floor((mercXY.x-radius)/g_config.TILE_SIZE);
	int nt=(int)floor((mercXY.y+radius)/g_config.TILE_SIZE);
	int nb=(int)floor((mercXY.y-radius)/g_config.TILE_SIZE);
	//Log.i("ItemizedOverlay","getTouchTiles er,el,nt,nb,z,mercX,mercY:"+er+","+el+","+nt+","+nb+","+z+","+mercX+","+mercY);
	for(int i=nb;i<=nt;i++){
		for(int j=el;j<=er;j++){
			deCartaTile * tile=[[deCartaTile alloc] initWithMapLayerProperty:[deCartaMapLayerProperty getInstance:STREET]];
			
			tile.xyz.x=j;
			tile.xyz.y=i;
			tile.xyz.z=z;
			[tiles addObject:tile];
			[tile release];
			
			
		}
	}
	
	return tiles;
}

+ (BOOL)covered:(deCartaXYZ *)xyz byTiles:(NSSet *)xyzs z:(int)z blX:(int)blX blY:(int)blY trX:(int)trX trY:(int)trY{
    BOOL covered=true;
    if(z<=xyz.z){
        float scale=((float)1)/(1<<(xyz.z-z));
        xyz.x=[deCartaUtil indexXMod:xyz.x atZoom:xyz.z];
        deCartaXYZ *coverXYZ=[[[deCartaXYZ alloc] initWithX:(int)floor(xyz.x*scale) andY:(int)floor(xyz.y*scale) andZ:z] autorelease];
        covered=[xyzs containsObject:coverXYZ];
    }else{
        int expand=1<<(z-xyz.z);
        int xmin=xyz.x*expand;
        int xmax=(xyz.x+1)*expand-1;
        int ymin=xyz.y*expand;
        int ymax=(xyz.y+1)*expand-1;
        if(xmin<blX) xmin=blX;
        if(xmax>trX) xmax=trX;
        if(ymin<blY) ymin=blY;
        if(ymax>trY) ymax=trY;
        
        if(xmin>xmax || ymin>ymax){
            [deCartaLogger warn:[NSString stringWithFormat:@"Util coveredByTiles xyz:%@ invisible,z:%d,blx:%d,blY:%d,trX:%d,trY:%d",[xyz description],z,blX,blY,trX,trY]];
            return true;
        }
        for(int i=ymin;i<=ymax;i++){
            for(int j=xmin;j<=xmax;j++){
                deCartaXYZ *coverXYZ=[[[deCartaXYZ alloc] initWithX:j andY:i andZ:z] autorelease];
                coverXYZ.x=[deCartaUtil indexXMod:coverXYZ.x atZoom:coverXYZ.z];
                if(![xyzs containsObject:coverXYZ]){
                    covered= false;
                    break;
                }
            }
            if(!covered) break;
        }
        
    }
    return covered;
    
}

@end