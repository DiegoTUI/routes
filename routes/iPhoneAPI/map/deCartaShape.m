//
//  deCartaShape.m
//  iPhoneApp
//
//  Created by Z.S. on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaShape.h"


@implementation deCartaShape
@synthesize name=_name;
@synthesize visible=_visible;
@synthesize fillColor=_fillColor;
@synthesize opacity=_opacity;

-(id)initWithName:(NSString *)inShapeName{
	
	if(inShapeName==nil || [inShapeName characterAtIndex:0] ==' ' || [inShapeName characterAtIndex:[inShapeName length]-1]==' '){
		[NSException exceptionWithName:@"InvalidShapeName" reason:@"Shape name can't begin or end with space" userInfo:nil];
	}
	self=[super init];
    if(self){
		_name=[inShapeName retain];
		self.visible=true;
	}
	
	return self;
}

-(void)dealloc{
	[_name release];
	[_eventListeners release];
	[super dealloc];
}

-(BOOL)addEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	if([_eventListeners objectForKey:[NSNumber numberWithInt:eventType]]==nil){
		[_eventListeners setObject:[NSMutableArray arrayWithCapacity:1] forKey:[NSNumber numberWithInt:eventType]];
	}
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array addObject:listener];
	
	return TRUE;
}
-(void)removeEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array removeObject:listener];
}
-(void)removeEventListeners:(int)eventType{
	[_eventListeners removeObjectForKey:[NSNumber numberWithInt:eventType]];
	
}

-(void)executeEventListeners:(int)eventType withParam:(id)param{
	NSArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	for(deCartaEventListener * listener in array){
		(listener.callback)(self,param);
	}
}

	
@end
