//
//  deCartaRouteAddress.h
//  iPhoneApp
//
//  Created by Z.S. on 3/7/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaPosition.h"

/*!
 * @internal No longer used by the deCarta iPhone API
 */
@interface deCartaRouteAddress : NSObject {
	NSString * _name;
	deCartaPosition * _position;
	
}
@property(nonatomic,retain) NSString * name;

@property(nonatomic,retain) deCartaPosition * position;

-(id)initWithName:(NSString *)name position:(deCartaPosition *)position;

@end
