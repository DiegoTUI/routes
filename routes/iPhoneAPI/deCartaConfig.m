//
//  CONFIG.m
//  iPhoneApp
//
//  Created by Z.S. on 1/31/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaConfig.h"
#import "deCartaLogger.h"

deCartaConfigStruct g_config={
    .clientName = @"",
    .clientPassword = @"",
    .host = @"",
    .configuration_default = @"",
    .configuration_high_res = @"",
    .transparentConfiguration = @"",
	
    .TILE_SIZE = 256,
    .TILE_THREAD_COUNT = 5,
    .CACHE_SIZE = 3000,
    .ONLY_CACHE_NETWORK_SLOW=FALSE,
    .ZOOM_LOWER_BOUND = 1,
    .ZOOM_UPPER_BOUND = 20,
    .SNAP_TO_CLOSEST_ZOOMLEVEL=TRUE,
    .FADING_TIME = 0.2,
    .ENABLE_TILT=FALSE,
    .ENABLE_ROTATE=FALSE,
    .COMPASS_PLACE_LOCATION = -1,
    .BORDER = 0,
    .DECELERATE = 0.8,
    //.BACKGROUND_COLOR=0xfff5f6f1,
    .BACKGROUND_COLOR=0xff000000,
    .BACKGROUND_GRID_COLOR=0xffcde2e7,
    
    .LOG_LEVEL = 3,
    .LOG_SIZE = 200,
    
    .TILE_URL_SUFFIX = @"/openls/image-cache/TILE",
	
    .STATELESS_SESSION_ID = 1,
    .IMAGE_FORMAT = @"PNG",
    .REAL_TIME_TRAFFIC=FALSE,
    .REL = @"4.5.1",
    .SATELLITE_KEY = @"2hq3AwyaQsMahDA5vYh1iBTaCMlFojTxLtCuzcIT2Ip7dY5d04VLPJEZvSSQd8u9"

};


@implementation deCartaConfig

+(void)printConfig{
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig clientName:%@",g_config.clientName]];
	
    NSMutableString * pw=[NSMutableString stringWithCapacity:[g_config.clientPassword length]];
    if([g_config.clientPassword length]>=1){
        [pw appendString:[g_config.clientPassword substringToIndex:1]];
        for(int i=1;i<[g_config.clientPassword length];i++){
            [pw appendString:@"*"];
        } 
    }
    [deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig clientPassword:%@",pw]];
    
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig host:%@",g_config.host]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig configuration_default:%@",g_config.configuration_default]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig configuration_high_res:%@",g_config.configuration_high_res]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig transparentConfiguration:%@",g_config.transparentConfiguration]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig TILE_SIZE:%d",g_config.TILE_SIZE]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig TILE_THREAD_COUNT:%d",g_config.TILE_THREAD_COUNT]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig CACHE_SIZE:%d",g_config.CACHE_SIZE]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig SNAP_TO_CLOEST_ZOOMLEVEL:%@",g_config.SNAP_TO_CLOSEST_ZOOMLEVEL?@"true":@"false"]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig ENABLE_TILT:%@",g_config.ENABLE_TILT?@"true":@"false"]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig ENABLE_ROTATE:%@",g_config.ENABLE_ROTATE?@"true":@"false"]];
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig COMPASS_PLACE_LOCATION:%d",g_config.COMPASS_PLACE_LOCATION]];
	
	[deCartaLogger info:[NSString stringWithFormat:@"deCartaConfig LOG_LEVEL:%d",g_config.LOG_LEVEL]];
}
@end
