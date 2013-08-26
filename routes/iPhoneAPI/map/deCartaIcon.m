//
//  deCartaIcon.m
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaIcon.h"


@implementation deCartaIcon
@synthesize size=_size;
@synthesize offset=_offset;
@synthesize image=_image;

-(id)initWithImage:(UIImage *)image{
	self=[super init];
    if(self){
		self.image=image;
		int width=roundf([image size].width);
		int height=roundf([image size].height);
		self.size=[[[deCartaXYInteger alloc] initWithXi:width andYi:height] autorelease];
		self.offset=[[[deCartaXYInteger alloc] initWithXi:width/2 andYi:height] autorelease];
	}
	
	return self;
}

-(id)initWithImage:(UIImage *)image size:(deCartaXYInteger *)size offset:(deCartaXYInteger *)offset{
	self=[super init];
    if(self){
		self.image=image;
		self.size=size;
		self.offset=offset;
	}		
	return self;
}

-(id) copyWithZone:(NSZone *)zone{
	deCartaIcon * icon=[[deCartaIcon allocWithZone:zone] initWithImage:self.image size:self.size offset:self.offset];
	return icon;
}

-(BOOL)isEqual:(id)obj{
	if(obj==nil) return FALSE;
	if(![obj isKindOfClass:[deCartaIcon class]]) return FALSE;
	deCartaIcon * i=(deCartaIcon *)obj;
	return self.image==i.image && [self.size isEqual:i.size] && [self.offset isEqual:i.offset];
}

-(NSUInteger)hash{
	unsigned int h = 5;
	h = 53 * h + (self.size != nil ? [self.size hash] : 0);
	h = 53 * h + (self.offset != nil ? [self.offset hash] : 0);
	h = 53 * h + (self.image != nil ? [self.image hash] : 0);
	return h;
}

-(void)dealloc{
	[_image release];
	[_size release];
	[_offset release];
	[super dealloc];
}
	
@end
