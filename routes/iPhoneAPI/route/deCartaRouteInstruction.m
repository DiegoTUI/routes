//
//  deCartaRouteInstruction.m
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaRouteInstruction.h"


@implementation deCartaRouteInstruction
@synthesize duration=_duration;
@synthesize distance=_distance;
@synthesize instruction=_instruction;
@synthesize position=_position;
@synthesize tour=_tour;

-(void)dealloc{
	[_duration release];
	[_distance release];
	[_instruction release];
	[_position release];
	[_tour release];
	[super dealloc];
}

@end
