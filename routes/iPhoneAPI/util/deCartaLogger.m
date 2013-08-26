//
//  deCartaLogger.m
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaLogger.h"
#import "deCartaConfig.h"

static NSMutableArray * content=nil;

@implementation deCartaLogger

+(void)initialize
{
    content=[[NSMutableArray alloc] initWithCapacity:g_config.LOG_SIZE+10];
}

+(NSArray *)getContent{
    return content;
}

+(void)debugws:(NSData *) inData tag:(NSString *)tag{
    if (g_config.LOG_LEVEL < LOG_LEVEL_DEBUG)
	{
		return;
	}
	else
	{
		NSString * ws=[NSString stringWithUTF8String:[inData bytes]];
        if(ws==nil){
            NSLog(@"WS %@: not null terminated",tag);
            ws=[[[NSString alloc] initWithData:inData encoding:NSUTF8StringEncoding] autorelease];
        }
        NSLog(@"WS %@: %@", tag, ws);
        
        [content insertObject:[NSString stringWithFormat:@"WS %@: %@", tag, ws] atIndex:0];
        if([content count]>g_config.LOG_SIZE){
            [content removeLastObject];
        }
    }
}

+ (void) debug:(NSString *) inMessage
{
	if (g_config.LOG_LEVEL < LOG_LEVEL_DEBUG)
	{
		return;
	}
	else
	{
		NSLog(@"DEBUG: %@", inMessage);
        
        [content insertObject:[NSString stringWithFormat:@"DEBUG: %@", inMessage] atIndex:0];
        if([content count]>g_config.LOG_SIZE){
            [content removeLastObject];
        }
	}
}

+ (void) info:(NSString *) inMessage;
{
	if (g_config.LOG_LEVEL < LOG_LEVEL_INFO)
	{
		return;
	}
	else
	{
		NSLog(@"INFO: %@", inMessage);	
        
        [content insertObject:[NSString stringWithFormat:@"INFO: %@", inMessage] atIndex:0];
        if([content count]>g_config.LOG_SIZE){
            [content removeLastObject];
        }

    
    }
}

+ (void) warn:(NSString *) inMessage;
{
	if (g_config.LOG_LEVEL < LOG_LEVEL_WARN)
	{
		return;
	}
	else
	{
		NSLog(@"WARN: %@", inMessage);
        
        [content insertObject:[NSString stringWithFormat:@"WARN: %@", inMessage] atIndex:0];
        if([content count]>g_config.LOG_SIZE){
            [content removeLastObject];
        }

	}
}

+ (void) fatal: (NSString *) inMessage;
{
	if (g_config.LOG_LEVEL < LOG_LEVEL_FATAL)
	{
		return;
	}
	else
	{
		NSLog(@"FATAL: %@", inMessage);	
        
        [content insertObject:[NSString stringWithFormat:@"FATAL: %@", inMessage] atIndex:0];
        if([content count]>g_config.LOG_SIZE){
            [content removeLastObject];
        }

    
    }
}
@end
