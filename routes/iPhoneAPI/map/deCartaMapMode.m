//
//  MapMode.m
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//


#import "deCartaMapMode.h"
#import "deCartaConfig.h"
#import "deCartaGlobals.h"

static int PERSPECTIVE_DEGREE=15;
static float MAX_PERSPECTIVE_RATIO=0.5f;
static float Y_SAME_HEIGHT=-1/4.0f;
//static float Y_SAME_HEIGHT=0;
static int DELAY_ANGLE=15;

@implementation deCartaMapMode

@synthesize nearZ=_nearZ,middleZ=_middleZ,farZ=_farZ;
@synthesize xRotating=_xRotating,zRotating=_zRotating;
@synthesize xRotationEnd=_xRotationEnd,zRotationEnd=_zRotationEnd;
@synthesize xRotationEndTime=_xRotationEndTime,zRotationEndTime=_zRotationEndTime;
@synthesize xRotation=_xRotation,zRotation=_zRotation,scale=_scale;
@synthesize cosX=_cosX,sinX=_sinX,cosZ=_cosZ,sinZ=_sinZ;
@synthesize displaySizeConvXR=_displaySizeConvXR,displaySizeConvXL=_displaySizeConvXL,displaySizeConvYT=_displaySizeConvYT,displaySizeConvYB=_displaySizeConvYB;
@synthesize gridSizeConvXR=_gridSizeConvXR,gridSizeConvXL=_gridSizeConvXL,gridSizeConvYT=_gridSizeConvYT,gridSizeConvYB=_gridSizeConvYB;

-(id)init{
	self=[super init];
    if(self){
		_nearZ=1024;
		_middleZ=2048;
		_farZ=_middleZ;
		
		_xRotationEnd=0;
		_xRotationEndTime=0;
		_xRotating=NO;
		
		_zRotationEnd=0;
		_zRotationEndTime=0;
		_zRotating=NO;
		
		_xRotation=0;
		_zRotation=0;
		_scale=_middleZ/(float)_nearZ;
		_cosX=1;
		_sinX=0;
		_cosZ=1;
		_sinZ=0;
		
		_displaySizeConvXR=0;
		_displaySizeConvXL=0;
		_displaySizeConvYT=0;
		_displaySizeConvYB=0;
		_gridSizeConvXR=0;
		_gridSizeConvXL=0;
		_gridSizeConvYT=0;
		_gridSizeConvYB=0;
	}
	
	
	return self;
}

-(void)resetXEasing{
	_xRotationEnd=0;
	_xRotationEndTime=0;
	_xRotating=FALSE;
}

-(void)resetZEasing{
	_zRotationEnd=0;
	_zRotationEndTime=0;
	_zRotating=FALSE;
}

-(void)setXRotation:(float)inXRotation withDisplaySize:(deCartaXYInteger *)inDisplaySize{
	if(!g_config.ENABLE_TILT) return;
	
	
	if(inXRotation>0){
		inXRotation=0;
	}
	else if(inXRotation<MAP_TILT_MIN){
		inXRotation=MAP_TILT_MIN;
	}
	_xRotation=inXRotation;
	_cosX=cosf(_xRotation*M_PI/180);
	_sinX=sinf(_xRotation*M_PI/180);
	[self configViewSize:inDisplaySize];
}

-(void)setZRotation:(float)inZRotation withDisplaySize:(deCartaXYInteger *)inDisplaySize{
	if(!g_config.ENABLE_ROTATE) return;
	
	inZRotation=(((int)inZRotation+180)%360+360)%360-180+(inZRotation-(int)inZRotation);
	_zRotation=inZRotation;
	_cosZ=cosf(_zRotation*M_PI/180);
	_sinZ=sinf(_zRotation*M_PI/180);
	[self configViewSize:inDisplaySize];
}

-(void)configViewDepth:(deCartaXYInteger *)displaySize{
	if(!g_config.ENABLE_TILT) return;
	
	float perspectiveTan=tanf(PERSPECTIVE_DEGREE*M_PI/180);
	float maxPTan=displaySize.x/(float)displaySize.y*MAX_PERSPECTIVE_RATIO;
	perspectiveTan=MIN(perspectiveTan,maxPTan);
	
	double cosX=cos(MAP_TILT_MIN*M_PI/180);
	double sinX=sin(MAP_TILT_MIN*M_PI/180);
	
	_nearZ=(int)ceil(displaySize.x/2.0f*(-sinX)/(perspectiveTan*cosX));
	int mz=(int)ceil(_nearZ+displaySize.y/2.0f*(-sinX)/cosX);
	_middleZ=_nearZ*2;
	while(_middleZ<mz){
		_middleZ+=_nearZ;
	}
	
	_farZ=(int)ceil((_middleZ*displaySize.y/2.0f)/(_nearZ*cosX-displaySize.y/2.0f*(-sinX))*(-sinX))+_middleZ;
	
	
}

-(void)configViewSize:(deCartaXYInteger *)displaySize{
	int tileSize=g_config.TILE_SIZE;
	float yHeight=Y_SAME_HEIGHT*displaySize.y;
	_scale=(float)(_middleZ/(_nearZ*_cosX+(yHeight*(-_sinX))));
	
	double yT=(_middleZ*(-displaySize.y/2.0f))/(_nearZ*_scale*_cosX-(-displaySize.y/2.0f)*_scale*_sinX);
	double xT=((displaySize.x/2.0f)*_middleZ+(displaySize.x/2.0f)*_scale*yT*_sinX)/(_nearZ*_scale);
	double dT=sqrt(xT*xT+yT*yT);
	
	double yB=(_middleZ*(displaySize.y/2.0f))/(_nearZ*_scale*_cosX-(displaySize.y/2.0f)*_scale*_sinX);
	double xB=((displaySize.x/2.0f)*_middleZ+(displaySize.x/2.0f)*_scale*yB*_sinX)/(_nearZ*_scale);
	double dB=sqrt(xB*xB+yB*yB);
	
	float cosTmZ=(float)(xT/dT*_cosZ+yT/dT*_sinZ);
	float cosTpZ=(float)(xT/dT*_cosZ-yT/dT*_sinZ);
	float sinTmZ=(float)(yT/dT*_cosZ-xT/dT*_sinZ);
	float sinTpZ=(float)(yT/dT*_cosZ+xT/dT*_sinZ);
	float convX1T=(float)ABS(dT*cosTmZ);
	float convX2T=(float)ABS(dT*cosTpZ);
	float convY1T=(float)ABS(dT*sinTpZ);
	float convY2T=(float)ABS(dT*sinTmZ);
	
	float cosBmZ=(float)(xB/dB*_cosZ+yB/dB*_sinZ);
	float cosBpZ=(float)(xB/dB*_cosZ-yB/dB*_sinZ);
	float sinBmZ=(float)(yB/dB*_cosZ-xB/dB*_sinZ);
	float sinBpZ=(float)(yB/dB*_cosZ+xB/dB*_sinZ);
	float convX1B=(float)ABS(dB*cosBmZ);
	float convX2B=(float)ABS(dB*cosBpZ);
	float convY1B=(float)ABS(dB*sinBpZ);
	float convY2B=(float)ABS(dB*sinBmZ);
	
	if(_zRotation>=DELAY_ANGLE && _zRotation<=180-DELAY_ANGLE){
		_displaySizeConvXR=MAX(convX1B, convX2B);
	}else{
		_displaySizeConvXR=MAX(convX1T, convX2T);
	}
	if(_zRotation>=-(180-DELAY_ANGLE) && _zRotation<=-DELAY_ANGLE){
		_displaySizeConvXL=MAX(convX1B, convX2B);
	}else{
		_displaySizeConvXL=MAX(convX1T, convX2T);
	}
	
	if(_zRotation>=-(90-DELAY_ANGLE) && _zRotation<=90-DELAY_ANGLE){
		_displaySizeConvYB=MAX(convY1B, convY2B);
	}else{
		_displaySizeConvYB=MAX(convY1T, convY2T);
	}
	if((_zRotation>=(90+DELAY_ANGLE) && _zRotation<=180) 
	   || (_zRotation>=-180 && _zRotation<-(90+DELAY_ANGLE))){
		_displaySizeConvYT=MAX(convY1B, convY2B);
	}else{
		_displaySizeConvYT=MAX(convY1T, convY2T);
	}
	
	_gridSizeConvXR=(int) ceil(_displaySizeConvXR/tileSize) + 1;
	_gridSizeConvXL=(int) ceil(_displaySizeConvXL/tileSize) + 1;
	_gridSizeConvYB=(int) ceil(_displaySizeConvYB/tileSize) + 1;
	_gridSizeConvYT=(int) ceil(_displaySizeConvYT/tileSize) + 1;
	
		
}


@end
