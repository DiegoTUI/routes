//
//  deCartaPin.m
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaPin.h"
#import "deCartaUtil.h"
#import "deCartaGlobals.h"

@implementation deCartaPin
@synthesize icon=_icon;
@synthesize message=_message;
@synthesize visible=_visible;
@synthesize ownerOverlay=_ownerOverlay;
@synthesize rotationTilt=_rotationTilt;
@synthesize poi=_poi;
@synthesize associatedObject=_associatedObject;


-(id)initWithPosition:(deCartaPosition *)position icon:(deCartaIcon *)icon 
						message:(NSString *)message rotationTilt:(deCartaRotationTilt *)rt{
	self=[super init];
    if(self){
		_icon=nil;
		_mercXY=nil;
		_message=nil;
		_visible=TRUE;
		_eventListeners=[[NSMutableDictionary alloc] init];
		_ownerOverlay=nil;
		_rotationTilt=nil;
		_poi=nil;
        _associatedObject=nil;
		
		self.position=position;
		self.icon=icon;
		self.message=message;
		_rotationTilt=[rt retain];
	}
	
	
	return self;
	
}

-(deCartaXYDouble *)mercXY{
    return _mercXY;
}
-(void)setMercXY:(deCartaXYDouble *)mercXY{
    deCartaXYDouble *oldMercXY=[[_mercXY retain] autorelease];
    if(mercXY==nil){
        if(_mercXY!=nil){
            [_mercXY release];
            _mercXY=nil;
            [_ownerOverlay performSelector:@selector(changePinPos:oldMercXY:) withObject:self withObject: oldMercXY];
        }
    }else{
        if(![mercXY isEqual:_mercXY]){
            [_mercXY release];
            _mercXY=[mercXY retain];
            [_ownerOverlay performSelector:@selector(changePinPos:oldMercXY:) withObject:self withObject: oldMercXY];
        }
    }
}
-(deCartaPosition *)position{
    return [deCartaUtil mercPixToPos:_mercXY atZoom:ZOOM_LEVEL];
}
-(void)setPosition:(deCartaPosition *)position{
	@try{
		if(position==nil){
			[self setMercXY:nil];
            
		}
        else {
            [self setMercXY:[deCartaUtil posToMercPix:position atZoom:ZOOM_LEVEL]];
        }
	}
	@catch(NSException * e){
		[_mercXY release];
		_mercXY=nil;
		@throw e;
	}
}

-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[deCartaPin class]]){
        deCartaPin *pin=object;
        return [pin.mercXY isEqual:_mercXY] &&[pin.icon isEqual:_icon] && [pin.message isEqual:_message];
        
    }else return FALSE;
}

-(void)dealloc{
	[_mercXY release];
	[_ownerOverlay release];
	[_message release];
	[_icon release];
	[_rotationTilt release];
	[_poi release];
    [_associatedObject release];
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
