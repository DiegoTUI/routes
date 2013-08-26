//
//  deCartaMapView.h
//  iPhoneApp
//
//  Created by Z.S. on 1/27/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//
#ifndef DECARTAMAPVIEW_H
#define DECARTAMAPVIEW_H

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "deCartaMapMode.h"
#import "deCartaInfoWindow.h"
#import "deCartaCompass.h"
#import "deCartaOverlay.h"

#import "deCartaPosition.h"

#import "deCartaXYInteger.h"
#import "deCartaXYFloat.h"
#import "deCartaXYDouble.h"
#import "deCartaXYZ.h"
#import "deCartaDictionary.h"

#import "deCartaTileThreadPool.h"
#import "deCartaEventSource.h"
#import "deCartaShape.h"


/*! @internal No longer used */
typedef struct{
	__unsafe_unretained NSString * routeId;
	BOOL realTimeTraffic;
}deCartaMapPreferenceStruct;

#pragma mark -
#pragma mark @structs used only in API

/*! @internal For internal API use only */
typedef struct{
	int capacity;
	double *times;
	__unsafe_unretained deCartaXYFloat **screenXYs;
	int index;
	int size;
}TouchRecord;

/*! @internal For internal API use only */
typedef struct{
	double TIME_SCALE;
	double MAXIMUM_SPEED;
	double MINIMUM_SPEED_RATIO;
	double CUTOFF_SPEED;
	
	double decelerateRate;
	double speed;
	double startMoveTime;
	float movedDistance;
	__unsafe_unretained deCartaXYFloat * direction;
    
    __unsafe_unretained deCartaEventListener * listener;
}EasingRecord;

/*! @internal For internal API use only */
typedef struct{
	int zoomToLevel;
	double digitalZoomEndTime;
    double speed;
	BOOL digitalZooming;
	__unsafe_unretained deCartaXYFloat * zoomCenterXY;
    
    __unsafe_unretained deCartaEventListener * listener;
}ZoomingRecord;

/*!
 * @ingroup Map
 * @class deCartaMapView
 * This class is the primary class for maintaining and displaying a visible
 * map. The methods and properties of this class allow for controlling various
 * map display properties, as well as offering the ability to overlay various
 * objects on the map display such as a deCartaInfoWindow, a deCartaCompass,
 * one or more deCartaOverlay objects (containing various deCartaPin objects), 
 * or deCartaShapes (such as deCartaCircle, deCartaPolygon, or deCartaPolyline).
 * The deCartaMapView class inherits from the deCartaEventSource class, and
 * extends the class by adding functionality for triggering events. Each of
 * the following event types (defined by the EventTypeEnum) will cause the
 * deCartaMapView class to call and of it's listeners (deCartaEventListener
 * objects): LONGTOUCH, TOUCH, DOUBLECLICK, MOVEEND, ZOOMEND, ROTATEEND,
 * TILTEND
 * @brief The primary class for displaying and managing a map.
 */
@interface deCartaMapView: UIView <deCartaEventSource>{
@private
    //variables for GLView
    EAGLContext *_context;
	
    // The pixel dimensions of the CAEAGLLayer.
    GLint _framebufferWidth;
    GLint _framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint _defaultFramebuffer, _colorRenderbuffer;
	
    BOOL _animating;

    /*! @internal For Internal API use only.
     * Use of the CADisplayLink class is the preferred method for controlling
     * your animation timing. CADisplayLink will link to the main display and 
     * fire every vsync when added to a given run-loop.
     * The NSTimer object is used only as fallback when running on a pre-3.1
     * device where CADisplayLink isn't available.
     */
    id _displayLink;
	

@private
	
	
    NSMutableDictionary * _eventListeners;
	
    //int _visibleLayerNum;
    NSMutableArray * _overlays;
    NSMutableArray * _shapes;
    deCartaInfoWindow * _infoWindow;
    deCartaXYInteger * _gridSize;
    deCartaXYInteger * _displaySize;
    deCartaXYFloat * _offset;
    double _radiusX;
    double _radiusY;
    deCartaXYInteger *_panDirection;
	
    NSMutableArray * _mapLayers;
	
    deCartaDictionary * _tileImages;
    deCartaDictionary * _tileTextureRefs;
    deCartaDictionary * _iconPool;
    deCartaDictionary * _clusterTextPool;
    deCartaMapTypeEnum _mapType;
    deCartaXYZ * _centerXYZ;
    deCartaXYDouble * _centerXY;
    deCartaXYFloat * _centerDelta;
    double _fadingStartTime;
	
    deCartaTileThreadPool * _tileThreadPool;
	
    float _zoomLevel;
    BOOL _zooming;
	
    ZoomingRecord _zoomingRecord;
    deCartaXYFloat * _lastCenterConv;
    BOOL _multiTouch;
    deCartaXYFloat * _lastTouchConv;
    deCartaXYFloat * _lastTouch;
    TouchRecord _touchRecord1;
    EasingRecord _easingRecord;
    BOOL _infoWindowClicked;
    BOOL _longClicked;
    double _lastTouchDownTime;
    deCartaXYFloat * _lastTouchDown;
    float _maxMoveFromTouchDown;
    double _lastTouchUpTime;
    deCartaXYFloat * _lastTouchUp;
    float _lastDistConv;
    deCartaXYFloat * _lastDirection;
    deCartaXYFloat * _lastTouchY;
    int _touchMode;
    TouchRecord _touchRecord2;
    
    NSTimer * _longTouchTimer;
    NSObject *_longTouchLock;
    
    float _lastZoomLevel;
    float _lastXRotation;
    float _lastZRotation;
	
    deCartaMapMode * _mapMode;

    deCartaMapPreferenceStruct _mapPreference;
	
    NSObject * _drawingLock;
    BOOL _touching;
    NSCondition *_touchingLock;
    NSCondition *_movingLock;
    
    NSMutableArray * _drawingTiles;
    deCartaCompass * _compass;
}

#pragma mark -
#pragma mark @definition GLView operation
/*! Activates map drawing. Once startAnimation is called, the map will continously
 * redraw until you call stopAnimation. startAnimation should be called only once
 * your application setup is complete and you want to begin rendering the map.
 */
- (void)startAnimation;

/*! Stops map drawing. */
- (void)stopAnimation;


#pragma mark -
#pragma mark @definition MapView operation

/*!
 * The current zoom level of the map. Zoom level is in the range 1.0
 * (zoomed-out) to 20.0 (zoomed-in).
 */
@property(nonatomic,assign)float zoomLevel;

/*!
 * Get current zRotation
 */
@property(nonatomic,readonly)float zRotation;

/*!
 * Get current xRotation
 */
@property(nonatomic,readonly)float xRotation;
 
/*! The deCartaInfoWindow object associated with the map view. Only one 
 * deCartaInfoWindow may be displayed on the map at any time.
 */
@property(nonatomic,retain,readonly) deCartaInfoWindow * infoWindow;

/*! The length, in meters, from the center of the viewable map to the right or left
 * edge of the map.
 */
@property(nonatomic,assign,readonly) double radiusX;

/*! The length, in meters, from the center of the viewable map to the top or bottom
 * edge of the map.
 */
@property(nonatomic,assign,readonly) double radiusY;

/*! The display size (width, height) of the map view portion of the screen. */
@property(nonatomic,retain,readonly) deCartaXYInteger * displaySize;

/*! @internal For internal API use only. */
@property(nonatomic,retain,readonly)NSObject * drawingLock;

@property(nonatomic,readonly)BOOL touching;
@property(nonatomic,retain,readonly)NSCondition *touchingLock;
@property(nonatomic,readonly)BOOL moving;
@property(nonatomic,retain,readonly)NSCondition *movingLock;

/*! @internal For internal API use only. */
@property(nonatomic,retain,readonly)deCartaDictionary * tileImages, * tileTextureRefs;

/*! The map type of this map (STREET_MAP_TYPE, SATELLITE_MAP_TYPE, or
 * HYBRID_MAP_TYPE. */
@property(nonatomic,assign,readonly)deCartaMapTypeEnum mapType;

/*! The deCartaCompass object associated with the map view. Only one
 * deCartaCompass may be displayed on the map at any time.
 */
@property(nonatomic,retain)deCartaCompass * compass;


/*!
 * Forces a refresh of the map display.
 */
-(void)refreshMap;

/*!
 * Sets the map type to display, defined by the deCartaMapTypeEnum
 * in deCartaGlobals.h (Street map, Satellite map, or hybrid).
 * @param mapType One of STREET_MAP_TYPE, SATELLITE_MAP_TYPE, or HYBRID_MAP_TYPE
 */
-(void)changeMapType:(deCartaMapTypeEnum)mapType;

/*!
 * Defines the tilt of the map (in degrees). 0.0 indicates a flat map, while
 * -45.0 indicates a map with the top tilted away from the viewer 45 degrees.
 * Values outside of the range -45.0 to 0.0 will be modified internally in 
 * the API to fit within that range.
 * @param xRotation A value, in degrees, from -45.0 to 0.0.
 */
-(void)rotateXToDegree:(float)xRotation;

/*!
 * Defines the rotation of the map (in degrees). Positive values up to 
 * 180.0 indicate that the map will be rotated clockwise, while negative
 * values down to -180.0 indicate that the map will be rotated
 * counterclockwise. The API accepts any value for degrees, and will convert
 * it internally to a value between -180.0 and 180.0.
 * @param zRotation Number of degrees to rotate the map (clockwise).
 */
-(void)rotateZToDegree:(float)zRotation;

/*!
 * Clears the map by removing all overlays, shapes, and info windows.
 */
-(void)clearMap;

/*!
 * Not Used.
 */
-(deCartaMapPreferenceStruct *)getMapPreferenceRef;


/*! Instantly centers the map on a specified geographic position.
 * @param inPos A deCartaPosition object representing the point on the map to
 * place at the center of the display.
 */
-(void)centerOnPosition:(deCartaPosition *)inPos;
//-(void)centerOnPosition:(deCartaPosition *)inPos zoomLevel:(float)inZoomLevel seedTileUrl:(NSString *)inSeedTile;

/*! Instantly centers the map on a specified geographic position, while also
 * adjusting zoom.
 * @param inPos A deCartaPosition object representing the point on the map to
 * place at the center of the display.
 * @param inZoomLevel A zoom level from 1.0 (zoomed-out) to 20.0 (zoomed-in)
 * @param specificHost Sets the deCarta DDS Web Services hostname for this and
 * all subsequent network requests. If set to nil, the hostname from the global
 * g_config.host configuration setting will be used.
 */
-(void)centerOnPosition:(deCartaPosition *)inPos zoomLevel:(float)inZoomLevel host:(NSString *)specificHost;

/*! Returns the hostname string currently used for deCarta DDS Web Services.
 * @return String indicating current DDS Web Services host name.
 */
-(NSString *)getSpecificHost;

/*! Gradually pans the map to a specified geographic position, placing the
 * specified position at the center of the visible map. Pans using 
 * default speed settings.
 * @param position A deCartaPosition object representing the point on the map
 * to pan to.
 */
-(void)panToPosition:(deCartaPosition *)position;

/*! Pans the map to a specified geographic position, placing the
 * specified position at the center of the visible map. The speed of the pan
 * is controlled by the duration, which determines how long the pan takes.
 * @param position A deCartaPosition object representing the point on the map
 * to pan to.
 * @param duration Duration of the pan, in seconds.
 * @param listener listener that will be called after this pan is done.
 */
-(void)panToPosition:(deCartaPosition *)position duration:(double)duration listener:(deCartaEventListener *)listener;

/*! Returns the geographic position at the center of the map.
 * @return Geographic point at map center
 */
-(deCartaPosition *)getCenterPosition;

/*! Converts a geographic position on the map to an X,Y pixel coordinate
 * on the screen
 * @param pos A deCartaPosition object representing a real-world geographic coordinate
 * @return An X,Y location on the screen (in pixels from the top-left corner
 * of the display). The returned X,Y coordinate could be beyond the screen
 * boundary if the geographic position is off the visible portion of the map.
 */
-(deCartaXYFloat *)positionToScreenXY:(deCartaPosition *)pos;

/*! Converts a screen coordinate to a real-world geographic position.
 * @param screenXY An X,Y screen location (in pixels from the top-left
 * corner of the display). The X,Y coordinate may lie beyond the bounds
 * of the real display.
 * @return A deCartaPosition object representing a real-world geographic
 * coordinate corresponding to the X,Y coordinate provided.
 */ 
-(deCartaPosition *)screenXYToPos:(deCartaXYFloat *)screenXY;

/*! Zooms in 1 level (=zoom level + 1), unless the zoom level is already
 * at maximum zoom (20). This zoom function zooms the map around the center
 * of the visible map.
 */
-(void)zoomIn;

/*! Zooms in, while leaving the zoomCenter (a geographic position on
 * the map) at the same point on the screen. Zooms in 1 level
 * (=zoom level + 1), unless the zoom level is already
 * at maximum zoom (20).
 * @param zoomCenter The geographic position that remains fixed, while
 * the rest of the map zooms relative to it.
 */
-(void)zoomInAtPosition:(deCartaPosition *)zoomCenter;

/*! Zooms out 1 level (=zoom level - 1), unless the zoom level is already
 * at minimum zoom (1). This zoom function zooms the map around the center
 * of the visible map.
 */
-(void)zoomOut;

/*! Zooms out, while leaving the zoomCenter (a geographic position on
 * the map) at the same point on the screen. Zooms out 1 level
 * (=zoom level - 1), unless the zoom level is already
 * at minimum zoom (1).
 * @param zoomCenter The geographic position that remains fixed, while
 * the rest of the map zooms relative to it.
 */
-(void)zoomOutAtPosition:(deCartaPosition *)zoomCenter;

/*! Zooms to a specific zoom level (1 to 20), while leaving the zoomCenter
 * (a geographic position on the map) at the same point on the screen.
 * @param inZ The specified zoom level
 * @param zoomCenter The geographic position that remains fixed, while
 * the rest of the map zooms relative to it.
 */
-(void)zoomTo:(int)inZ position:(deCartaPosition *)zoomCenter;

/*! Zooms directly to a specified zoom level (1 to 20). This zoom 
 * function zooms the map around the center of the visible map.
 * @param inZ The specified zoom level
 */
-(void)zoomTo:(int)inZ;

/*! Zooms directly to a specified zoom level at zoomCenter within specified duration and listener called after zoom is done
 */
-(void)zoomTo:(int)inZ position:(deCartaPosition *)zoomCenter duration:(double)duration listener:(deCartaEventListener *)listener;

/*! Zooms directly to a specified zoom level within specified duration and listener called after zoom is done
 */
-(void)zoomTo:(int)inZ duration:(double)duration listener:(deCartaEventListener *)listener;

/*! Provides the URL used for fetching the seed tile from the deCarta DDS
 * Web Service. Used for debugging.
 */
-(NSString *)getTemplateSeedTileUrl;

/*! Clear cached tiles
 */
-(void)clearCachedTiles;

-(void)waitForDrawDone;

#pragma mark -
#pragma mark @definition overlay operation
/*!
 * Adds a deCartaOverlay object (which is a collection of deCartaPin objects)
 * to the map for display.
 * @param overlay The specified deCartaOverlay object to display on the map.
 */
-(void)addOverlay:(deCartaOverlay *)overlay;

/*!
 * Deletes a deCartaOverlay object from the map (delete by index)
 * @param index The index of the deCartaOverlay object to delete.
 */
-(void)deleteOverlayAtIndex:(int)index;

/*!
 * Deletes a deCartaOverlay object from the map (delete by pointer)
 * @param overlay A pointer to the deCartaOverlay object to delete.
 */
-(void)deleteOverlay:(deCartaOverlay *)overlay;

/*!
 * Deletes a deCartaOverlay object from the map (delete by name)
 * @param name The NSString name that was given to the deCartaOverlay that
 * you want to delete.
 * @return A pointer to the deCartaOverlay object deleted.
 */
-(deCartaOverlay *)deleteOverlayByName:(NSString *)name;

/*! Deletes all overlays from the map.
 */
-(void)deleteOverlays;

/*!
 * Retrieves a deCartaOverlay from the map, by name.
 * @param name The NSString name that was given to the deCartaOverlay that
 * you want to retrieve.
 * @return A pointer to a deCartaOverlay object.
 */
-(deCartaOverlay *)getOverlayByName:(NSString *)name;

/*!
 * Retrieves a deCartaOverlay from the map, by index.
 * @param index The index of the deCartaOverlay object in the collection
 * of deCartaOverlay objects currently associated with the map.
 * @return A pointer to a deCartaOverlay object.
 */
-(deCartaOverlay *)getOverlay:(int)index;

/*! Hides all overlays on the map. */
-(void)hideOverlays;

/*! Shows all overlays on the map. */
-(void)showOverlays;

#pragma mark -
#pragma mark @defination shape operation

/*! Gets the number of shapes currently associated with the map.
 * @return Number of shapes.
 */
-(int)getShapesSize;

/*!
 * Retrieves the deCartaShape object at the specified index.
 * @param i Index of the deCartaShape to retrieve.
 * @return A pointer to the returned deCartaShape.
 */
-(deCartaShape *)getshapeAtIndex:(int)i;

/*!
 * Retrieves the deCartaShape object by name.
 * @param shapeName NSString name associated with the deCartaShape to retrieve.
 * @return A pointer to the returned deCartaShape.
 */
-(deCartaShape *)getShapeByName:(NSString *)shapeName;

/*!
 * Adds a deCartaShape for display on the map.
 * @param shape The deCartaShape to add to the map.
 */
-(void)addShape:(deCartaShape *)shape;

/*!
 * Removes all shapes from the map.
 */
-(void)removeShapes;

/*!
 * Removes a specific shape from the map, by index.
 * @param i The index of the deCartaShape in the map's collection of shapes.
 * @return The pointer to the deCartaShape that was removed.
 */
-(deCartaShape *)removeShapeAtIndex:(int)i;

/*!
 * Removes a specific shape from the map, by pointer.
 * @param shape A pointer to a deCartaShape to remove from the map's collection of shapes.
 */
-(void)removeShape:(deCartaShape *)shape;

/*!
 * Removes a specific shape from the map, by name.
 * @param shapeName The NSString name associated with the deCartaShape to remove from the map's collection of shapes.
 * @return The pointer to the deCartaShape that was removed.
 */
-(deCartaShape *)removeShapeByName:(NSString *)shapeName;


@end

#endif
