//
//  deCartaRotationTilt.m
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaRotationTilt.h"
#import "deCartaConfig.h"


@implementation deCartaRotationTilt
@synthesize rotateRelativeTo=_rotateRelativeTo;
@synthesize tiltRelativeTo=_tiltRelativeTo;
@synthesize rotation=_rotation,tilt=_tilt;
@synthesize cosR=_cosR,sinR=_sinR,cosT=_cosT,sinT=_sinT;

-(id)initWithRotateRelative:(RotateRelativeEnum)inRotateRelativeTo tiltRelative:(TiltRelativeEnum)inTiltRelativeTo{
	self=[super init];
    if(self){
		_rotateRelativeTo=inRotateRelativeTo;
		_tiltRelativeTo=inTiltRelativeTo;
		_rotation=0;
		_tilt=0;
		_cosR=1;
		_sinR=0;
		_cosT=1;
		_sinT=0;
	}
	
	return self;
}

-(id)init{
	return [self initWithRotateRelative:ROTATE_RELATIVE_TO_SCREEN tiltRelative:TILT_RELATIVE_TO_SCREEN];
}

+(id)rotationTilt{
	return [[[deCartaRotationTilt alloc] init] autorelease];
}

+(id)rotationTiltWithRotateRelative:(RotateRelativeEnum)inRotateRelativeTo tiltRelative:(TiltRelativeEnum)inTiltRelativeTo{
	return [[[deCartaRotationTilt alloc] initWithRotateRelative:inRotateRelativeTo tiltRelative:inTiltRelativeTo] autorelease];
}

-(void)setTilt:(float)inTilt{
	_tilt=inTilt;
	_cosT=cosf(_tilt*M_PI/180);
	_sinT=sinf(_tilt*M_PI/180);
}

-(void)setRotation:(float)inRotation{
	_rotation=inRotation;
	_cosR=cosf(_rotation*M_PI/180);
	_sinR=sinf(_rotation*M_PI/180);
}

@end
