//
//  deCartaImageUtil.m
//  iPhoneApp
//
//  Created by Z.S. on 2/17/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import "deCartaImageUtil.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "FastImage.h"

#import "deCartaLogger.h"

#include <TargetConditionals.h>

@implementation deCartaImageUtil

+(unsigned int)image2Texture:(UIImage *)image texRef:(unsigned int)texRef format:(deCartaImageFormatEnum)format size:(deCartaXYInteger *)size sizePower2:(deCartaXYInteger *)sizePower2{
	if (!image)	return FALSE;
	unsigned char * imgBuf=0;
	@try{
		deCartaImageFormatStruct * formatStruct=(deCartaImageFormatStruct *)&Image_Formats[format];
		CGImageRef img=image.CGImage;
		imgBuf=malloc(sizePower2.x*sizePower2.y*4);
		CGColorSpaceRef	colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(imgBuf, sizePower2.x, sizePower2.y, 8, sizePower2.x * 4, colorSpace, formatStruct->alphaInfo);
		CGRect rect = CGRectMake(0, sizePower2.y-size.y, size.x, size.y);
		CGContextClearRect(context, CGRectMake(0, 0, sizePower2.x, sizePower2.y));
		CGContextDrawImage(context, rect, img);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		
		if(format==RGB_565){
			unsigned char *src=(unsigned char *)imgBuf;
			
#if !(TARGET_IPHONE_SIMULATOR)
			FastImageRGBAtoRGB565(src, src, sizePower2.x * sizePower2.y);
#else
			unsigned short *dest=(unsigned short *)imgBuf;
			unsigned short pixel;
			for (int i = 0; i < sizePower2.x * sizePower2.y; i++)
			{
				pixel = ((*src++ >> 3) << 11);
				pixel |= ((*src++ >> 2) << 5);
				pixel |= ((*src++ >> 3));
				*dest++ = pixel;
				src++;
			}
#endif
		}
		
		glBindTexture(GL_TEXTURE_2D, texRef);
		glTexImage2D(GL_TEXTURE_2D, 0, formatStruct->texFormat, sizePower2.x, sizePower2.y, 0, formatStruct->texFormat, formatStruct->texType, imgBuf);
		
		free(imgBuf);
		return TRUE;
	}
	@catch (NSException * e) {
		[deCartaLogger warn:[NSString stringWithFormat:@"ImageUtil image2texture exception:%@",[e name]]];
		if(imgBuf) free(imgBuf);
		return FALSE;
	}
}	

@end
