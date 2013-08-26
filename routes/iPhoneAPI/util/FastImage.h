//
//  FastImage.h
//  iPhoneApp
//
//  Created by Z.S. on 3/24/11.
//  Copyright 2011 deCarta. All rights reserved.
//
//  FastImage.h
//  This FastImage code was written by Dan Posluns.



#include <TargetConditionals.h>

/*!
 * @internal All functions are only used inside API.
 */

#ifndef FASTIMAGE_H
#define FASTIMAGE_H

#if !(TARGET_IPHONE_SIMULATOR)

void FastImageRGBAtoRGB(const unsigned char *src, unsigned char *dest, int pixelCount);
int FastImageRLECompress(const unsigned int *src, unsigned int *dest, int pixelCount);
int FastImageRLEUncompress(const unsigned int *src, unsigned int *dest, int dataBytes);
void FastImageRGBAtoRGB565(const unsigned char *src, unsigned char *dest, int pixelCount);
void FastImagePremultiplyRGBA(const unsigned char *src, unsigned char *dest, int pixelCount);

#endif

#endif	//FASTIMAGE_H
