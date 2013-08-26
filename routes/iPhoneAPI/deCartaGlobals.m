//
//  deCartaGlobals.m
//  iPhoneApp
//
//  Created by Z.S. on 3/3/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "deCartaGlobals.h"
#import "deCartaMapLayer.h"

BOOL MapType_MapLayer_Visibility[][NUM_OF_MAPLAYER_TYPE]={
	{TRUE,FALSE,FALSE},
	{FALSE,TRUE,FALSE},
	{FALSE,TRUE,TRUE}
};

deCartaImageFormatStruct Image_Formats[]={
	{4,	kCGImageAlphaPremultipliedLast, GL_RGBA, GL_UNSIGNED_BYTE},
	{2,	kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big, GL_RGB, GL_UNSIGNED_SHORT_5_6_5}
};

float g_scale=1.0f;

long MERC_X_MODS[21];
int INDEX_X_MODS[21];

int MapLayer_Format[NUM_OF_MAPLAYER_TYPE]={RGB_565,RGB_565,RGBA};

@implementation deCartaGlobals

@end
