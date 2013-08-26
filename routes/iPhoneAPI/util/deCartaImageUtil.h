//
//  deCartaImageUtil.h
//  iPhoneApp
//
//  Created by Z.S. on 2/17/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "deCartaXYInteger.h"
#import "deCartaGlobals.h"

/*!
 * @internal This class is used inside API only
 */
@interface deCartaImageUtil : NSObject {

}

+(unsigned int)image2Texture:(UIImage *)image texRef:(unsigned int)texRef format:(deCartaImageFormatEnum)format size:(deCartaXYInteger *)size sizePower2:(deCartaXYInteger *)sizePower2;

@end
