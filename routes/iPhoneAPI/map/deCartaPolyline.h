//
//  deCartaPolyline.h
//  iPhoneApp
//
//  Created by Z.S. on 3/10/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaShape.h"
#import "deCartaEventSource.h"
#import "deCartaEventListener.h"
#import "deCartaXYDouble.h"
#import "deCartaXYZ.h"
#import "deCartaXYInteger.h"
#import "deCartaXYFloat.h"


/*!
 * @ingroup Map
 * @class deCartaPolyline
 * deCartaPolyline is an extension of deCartaShape that is intended for
 * rendering multi-segmented lines. 
 * The deCartaPolyline class inherits from the deCartaShape class, which
 * inherits from the deCartaEventSource class. So, deCartaPolyline could
 * theoretically support event-capturing, but this functionality is not
 * implemented, so a deCartaPolyline will not trigger any events.
 * @brief A multi-segment line
 */
@interface deCartaPolyline : deCartaShape  {
	int _strokeSize;
	NSArray * _positions;
	NSMutableArray * _mercXYs;
	NSMutableArray * _generalizedPosIdxs[21];
	NSMutableDictionary * _pointIdxs[21];
}
/*!
 * Integer stroke size, indicating line thickness, in pixels (up to 64)
 */
@property(nonatomic,assign)int strokeSize;

/*!
 * Array of deCartaPosition objects indicating the geographic coordinates
 * of the vertices of the line segments on a map.
 */
@property(nonatomic,retain)NSArray * positions;

/*!
 * @internal For internal use only
 */
@property(nonatomic,retain,readonly)NSArray * mercXYs;

/*!
 * Initializes the deCartaPolyline object with an array of deCartaPosition
 * objects indicating the vertices of the polyline, and a string indicating
 * the name of this polyline.
 * @param positions NSArray of deCartaPosition objects with the X,Y
 * coordinates of each vertex along the polyline.
 * @param name NSString name for this deCartaPolyline object.
 * @return Objective-C ID of the deCartaPolyline object returned
 */
-(id)initWithPositions:(NSArray *)positions name:(NSString *)name;

#pragma mark -
#pragma mark @definition methods used only in API

/*! @internal For internal use only */
-(void)renderGL:(deCartaXYDouble *)topLeftXY zoomLevel:(float)zoomLevel z:(int)z tiles:(NSArray *)drawTiles;

@end
