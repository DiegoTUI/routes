//
//  MapMode.h
//  iPhoneApp
//
//  Created by Z.S. on 2/9/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaXYInteger.h"

/*!
 * @internal
 * This class is only used inside API
 */
@interface deCartaMapMode : NSObject {
	int _nearZ;
	int _middleZ;
	int _farZ;
	
	float _xRotationEnd;
	double _xRotationEndTime;
	BOOL _xRotating;
	
	float _zRotationEnd;
	double _zRotationEndTime;
	BOOL _zRotating;
	
	float _xRotation;
	float _zRotation;
	float _scale;
	float _cosX;
	float _sinX;
	float _cosZ;
	float _sinZ;
	
	float _displaySizeConvXR;
	float _displaySizeConvXL;
	float _displaySizeConvYT;
	float _displaySizeConvYB;
	
	int _gridSizeConvXR;
	int _gridSizeConvXL;
	int _gridSizeConvYT;
	int _gridSizeConvYB;
	
}

@property(nonatomic,assign) int nearZ,middleZ,farZ;
@property(nonatomic,assign) float xRotationEnd,zRotationEnd;
@property(nonatomic,assign) double xRotationEndTime,zRotationEndTime;
@property(nonatomic,assign) BOOL xRotating,zRotating;
@property(nonatomic,assign,readonly) float xRotation,zRotation,scale;
@property(nonatomic,assign,readonly)float cosX,sinX,cosZ,sinZ;
@property(nonatomic,assign,readonly) float displaySizeConvXR,displaySizeConvXL,displaySizeConvYT,displaySizeConvYB;
@property(nonatomic,assign,readonly) int gridSizeConvXR,gridSizeConvXL,gridSizeConvYT,gridSizeConvYB;

-(void)resetXEasing;
-(void)resetZEasing;
-(void)setXRotation:(float)inXRotation withDisplaySize:(deCartaXYInteger *)inDisplaySize;
-(void)setZRotation:(float)inZRotation withDisplaySize:(deCartaXYInteger *)inDisplaySize;
-(float)xRotation;
-(float)zRotation;
-(float)cosX;
-(float)sinX;
-(float)cosZ;
-(float)sinZ;




-(void)configViewDepth:(deCartaXYInteger *)displaySize;
-(void)configViewSize:(deCartaXYInteger *)displaySize;

@end
