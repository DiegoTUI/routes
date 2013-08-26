//
//  deCartaDictionary.m
//  iPhoneApp
//
//  Created by Z.S. on 2/10/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaDictionary.h"
#import "deCartaLogger.h"

@implementation LinkedListNode
@synthesize value;
@synthesize key;
@synthesize after;
@synthesize before;

-(id)initWithValue:(id)inValue andKey:(id)inKey{
	self=[super init];
    if(self){
		self.value=inValue;
		self.key=inKey;
		self.after=nil;
		self.before=nil;
	}
	return self;
}

-(void)dealloc{
	[value release];
	[key release];
		
	return [super dealloc];
}

@end


@implementation deCartaDictionary
-(id)initWithSize:(int)inSize andDelFunc:(void(*)(id))inDelFunc{
	self=[super init];
    if(self){
		size=inSize;
		dic=[[NSMutableDictionary alloc] initWithCapacity:inSize];
		delFunc=inDelFunc;
		header=[[LinkedListNode alloc] initWithValue:nil andKey:nil];
		header.after=header;
		header.before=header;
		
	}
	return self;
}

-(void)setObject:(id)anObject forKey:(id)aKey{
	if(anObject==nil){
		[deCartaLogger warn:@"Dictionary setObject object nil"];
		return;
	}
	if(aKey==nil){
		[deCartaLogger warn:@"Dictionary setObject key nil"];
		return;
	}
	
	LinkedListNode * v=[[LinkedListNode alloc] initWithValue:anObject andKey:aKey];
	v.after=header;
	v.before=header.before;
	header.before.after=v;
	header.before=v;
	
	[dic setValue:v forKey:aKey];
	[v release];
	if([dic count]>size){
		LinkedListNode * vr=header.after;
		//[deCartaLogger debug:[NSString stringWithFormat:@"Dictionary setObject remove eldest key:%@",[vr.key description]]];
		vr.before.after=vr.after;
		vr.after.before=vr.before;
		id ov=[vr.value retain];
		[dic removeObjectForKey:vr.key];
		if(delFunc) delFunc(ov);
		[ov release];
	}
	
}

-(id)removeObjectForKey:(id)aKey andExecDelFunc:(BOOL)execDelFunc{
	LinkedListNode *vr=(LinkedListNode *)[dic objectForKey:aKey];
	if(vr==nil) return nil;
	vr.before.after=vr.after;
	vr.after.before=vr.before;
	id ov=[vr.value retain];
	[dic removeObjectForKey:aKey];
	if(execDelFunc && delFunc) delFunc(ov);
	return [ov autorelease];
}

-(id)objectForKey:(id)aKey{
	LinkedListNode *v=(LinkedListNode *)[dic objectForKey:aKey];
	if(v==nil) return nil;
	
	v.before.after=v.after;
	v.after.before=v.before;
	v.after=header;
	v.before=header.before;
	header.before.after=v;
	header.before=v;
	
	return v.value;
}

- (void)removeAllObjects{
	if(delFunc){
		for(LinkedListNode * vr in [dic allValues]){
			delFunc(vr.value);
		}
	}
	
	[dic removeAllObjects];
    header.after=header;
    header.before=header;
}

-(void)dealloc{
	[dic release];
	[header release];
	
	return [super dealloc];
}
	
@end
