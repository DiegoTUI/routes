//
//  deCartaShape.h
//  iPhoneApp
//
//  Created by Z.S on 2/25/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaEventSource.h"
#import "deCartaEventListener.h"

/*!
 * @ingroup Map
 * @class deCartaShape
 * A deCartaShape, and the subclasses deCartaCircle, deCartaPolyline and 
 * deCartaPolygon, are used to visually display an overlay on an 
 * initialized deCartaMap.
 * To use, simply create the shape, sometimes referred to as overlays, 
 * and add the shape to an instance of a deCartaMap with deCartaMap.addOverlay:.
 * @note Only the extended classes of deCartaShape can be drawn on 
 * a map. This class merely provides common methods shared by all 
 * shapes. 
 * The deCartaShape class is inherited from deCartaEventSource,
 * but does not currently trigger any events.
 * @brief Base class for all shapes (deCartaPolyline, deCartaPolygon, deCartaCircle)
 */
@interface deCartaShape : NSObject <deCartaEventSource>{
	NSString * _name;
	BOOL _visible;
	int _fillColor;
	float _opacity;
	NSMutableDictionary * _eventListeners;
	

}

/*! Name of the deCartaShape */
@property(nonatomic,readonly,retain) NSString * name;

/*! TRUE/FALSE visibility property */
@property(nonatomic,assign) BOOL visible;

/*!
 * The color of the shape or line. Defined in RGB format: 0xXXRRGGBB
 */
@property(nonatomic,assign) int fillColor;

/*!
 * Opacity of the shape, ranging from 0.0 (transparent) to 1.0 (opaque)
 */
@property(nonatomic,assign) float opacity;

/*!
 * Initializes a deCartaShape object with a name
 * @param inShapeName String indicating the name of the shape instance
 * @return Objective-C ID of the returned deCartaShape object
 */
-(id)initWithName:(NSString *)inShapeName;


@end
