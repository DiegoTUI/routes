//
//  deCartaOverlay.h
//  iPhoneApp
//
//  Created by Z.S. on 2/28/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "deCartaPin.h"
#import "deCartaXYDouble.h"
#import "deCartaMapMode.h"
#import "deCartaConfig.h"

#define OVERLAY_CLUSTER_BORDER_SIZE 1
#define OVERLAY_CLUSTER_ROUND_RADIUS 4
#define OVERLAY_CLUSTER_TEXT_SIZE 10
#define OVERLAY_CLUSTER_TEXT_OFFSET_X 2
#define OVERLAY_CLUSTER_TEXT_OFFSET_Y 1
#define OVERLAY_CLUSTER_TEXT_FONT_FAMILY @"Helvetica"

#define TOUCH_RADIUS 100
//#define SNAP_BUFFER 6
#define SNAP_BUFFER 0

typedef enum {
    OVERLAY_CLUSTER_TEXT_TOP_LEFT,
    OVERLAY_CLUSTER_TEXT_TOP_RIGHT,
    OVERLAY_CLUSTER_TEXT_BOTTOM_LEFT,
    OVERLAY_CLUSTER_TEXT_BOTTOM_RIGHT
}deCartaOffsetReference;

/*!
 * @ingroup Map
 * @class deCartaOverlay
 * A collection of pins which are organized into
 * a single map overlay. Use methods of the deCartaMapView class
 * such as deCartaMapView::addOverlay and deCartaMapView::deleteOverlay
 * to add or remove an overlay from the map.
 * @brief A map overlay (a collection of pins)
 */
@interface deCartaOverlay : NSObject {
	NSString * _name;
	NSMutableArray * _pins;
	NSMutableDictionary * _pinIdxs[21];
    
    BOOL _clustering;
    deCartaEventListener * _clusterTouchEventListener;
    deCartaXYInteger * _clusterTextOffset;
    deCartaOffsetReference _clusterTextOffsetRelativeTo;
    int _clusterBackgroundColor;
    int _clusterTextColor;
    int _clusterBorderColor;    
    
    NSObject *_idxLock;
	
}
/*! A name for this deCartaOverlay object */
@property(nonatomic,retain,readonly)NSString * name;

@property(nonatomic,assign) BOOL clustering;
@property(nonatomic,retain) deCartaEventListener * clusterTouchEventListener;
@property(nonatomic,retain) deCartaXYInteger * clusterTextOffset;
@property(nonatomic,assign) deCartaOffsetReference clusterTextOffsetRelativeTo;
@property(nonatomic,assign) int clusterBackgroundColor, clusterTextColor, clusterBorderColor;

/*! Creates a deCartaOverlay object with a specified string
 * for a name.
 * @param name Name (string) to assign to the created overlay
 * @return Objective C ID of the returned deCartaOverlay object
 */
-(id)initWithName:(NSString *)name;

/*! Returns the number of pins stored in this overlay
 * @return integer number of pins in the overlay
 */
-(int)size;

/*!
 * Retrieves a specific pin from the overlay.
 * @param i Integer index of the pin to retrieve.
 * @return A pointer to the deCartaPin object retrieved.
 */
-(deCartaPin *)getAtIndex:(int)i;

/*!
 * Adds a pin to this overlay.
 * @param pin A deCartaPin object to add to this overlay.
 */
-(void)addPin:(deCartaPin *)pin;

/*!
 * Removes all pins from the overlay.
 */
-(void)clear;

/*!
 * Removes a specified pin from the overlay, by index
 * @param i Index of the pin to remove
 * @return A pointer to the deCartaPin object removed from the overlay.
 */
-(deCartaPin *)removeAtIndex:(int)i;

/*!
 * Removes a specified pin from the overlay, by pointer
 * @param pin A pointer to a deCartaPin object to remove
 * @return TRUE if the pin was successfully removed, FALSE if an error occurred
 */
-(BOOL)removePin:(deCartaPin *)pin;

#pragma mark -
#pragma mark @definition methods used only in API

/*! @internal For internal use only */
-(NSMutableArray *)getVisiblePinsAtZ:(int)z tiles:(NSArray *)tiles;
/*! @internal For internal use only */
-(void) changePinPos:(deCartaPin *)pin oldMercXY:(deCartaXYDouble *)oldMercXY;


@end
