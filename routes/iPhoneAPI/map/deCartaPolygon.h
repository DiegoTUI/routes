//
//  deCartaPolygon.h
//  iPhoneRefApp
//
//  Created by Z.S. on 3/21/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaShape.h"
#import "deCartaXYDouble.h"


/*!
 * @ingroup Map
 * @class deCartaPolygon
 * deCartaPolygon is an extension of deCartaShape, one that is 
 * specifically geared towards displaying enclosed shapes on a deCartaMap. 
 * @brief An enclosed polygon
 */
@interface deCartaPolygon : deCartaShape {
	NSArray * _positions;
	NSMutableArray * _mercXYs;
}
/*!
 * An array of deCartaPosition objects which define the geographic positions
 * which constitute the vertices of the polygon on the map.
 */
@property(nonatomic,retain)NSArray * positions;

/*!
 * Initialize a deCartaPolygon object with an array of positions (which define
 * the polygon vertices), and a string name for the polygon.
 * @param positions An array of deCartaPosition objects for polygon vertices.
 * @param name NSString name of this deCartaPolygon object.
 * @return Objective-C ID of the returned polygon object.
 */
-(id)initWithPositions:(NSArray *)positions name:(NSString *)name;

#pragma mark -
#pragma mark @definition methods used only in API

/*! @internal For internal use only */
-(void)renderGL:(deCartaXYDouble *)topLeftXY  atZoom:(float)zoomLevel;

@end
