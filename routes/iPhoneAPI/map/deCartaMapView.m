//
//  MapView.m
//  iPhoneApp
//
//  Created by Z.S. on 1/27/11.
//  Copyright 2011 deCarta, Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "deCartaMapView.h"

#import "deCartaConfig.h"

#import "deCartaMapLayer.h"
#import "deCartaTile.h"
#import "deCartaTileGridResponse.h"
#import "deCartaLength.h"
#import "deCartaMapLayerProperty.h"

#import "deCartaUtil.h"
#import "deCartaLogger.h"
#import "deCartaImageUtil.h"
#import "deCartaWebServices.h"
#import "deCartaPolyline.h"
#import "deCartaCircle.h"
#import "deCartaPolygon.h"

#define DEFAULT_REFRESH_RATE 60

static float ZOOM_PENALTY=0.8f;
static double LONG_TOUCH_TIME_MIN=1;
static double CLICK_DOWN_UP_TIME_MAX=0.3;
static double DOUBLE_CLICK_INTERVAL_TIME_MAX=0.5;
static float SAME_POINT_MOVED_DISTANCE_MAX=30/1.5f;
static float MIN_PINCH_DISTANCE=150/1.5f;
static float MIN_ROTATE_DISTANCE=80/1.5f;
static float CLONE_MAP_LAYER_DRAW_PERCENT=0.4f;
//static float DRAW_ZOOM_LAYER_DRAW_PERCENT=0.8f;
static int FADING_START_ALPHA=30;
static float ABNORMAL_DRAGGING_DIST=800/1.5;
static float ABNORMAL_PINCH_CENTER_DIST=300/1.5;
static int ABNORMAL_ZROTATION=30;

static int MAX_TILE_IMAGE_DEF=70;
static int MAX_TILE_TEXTURE_REF_DEF=200;
static int MAX_ICON_SIZE=20;
static int MAX_CLUSTER_TEXT_SIZE=30;

static float XROTATION_YDIST=300/1.5;
static double XROTATION_TIME=0.5;
static double ZROTATION_TIME=0.5;

static float ZOOMING_LAG=0.1f;

static float Cos30=0.8660254f;
static float Cos60=0.5f;


//map render variables
static const GLbyte TEXTURE_COORDS[]={
	0,0,
	0,1,
	1,0,
	1,1
};
static GLfloat mVertexBuffer[8];

//following c functions are only used inside this file
void removeTexRef(id texRef){
	unsigned int a=[(NSNumber *)texRef intValue];
	if(a){
		glDeleteTextures(1, &a);
	}
	//[deCartaLogger debug:[NSString stringWithFormat:@"removeEldestTexRef remove:%d",a]];
	
}

void initTouchRecord(TouchRecord * tr,int capacity){
	tr->capacity=capacity;
	tr->index=-1;
	tr->size=0;
	tr->times=(double *)calloc(tr->capacity,sizeof(double));
	tr->screenXYs=(deCartaXYFloat **)calloc(tr->capacity, sizeof(deCartaXYFloat *));
	for(int i=0;i<tr->capacity;i++){
		tr->times[i]=0;
		tr->screenXYs[i]=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	}
}

void pushToTouchRecord(TouchRecord * tr,double time,float x,float y){
	tr->index=(tr->index+1)%tr->capacity;
	tr->screenXYs[tr->index].x=x;
	tr->screenXYs[tr->index].y=y;
	tr->times[tr->index]=time;
	
	tr->size++;
	if(tr->size>tr->capacity) tr->size=tr->capacity;
}

void resetTouchRecord(TouchRecord * tr){
	tr->index=-1;
	tr->size=0;
}

void freeTouchRecord(TouchRecord * tr){
	free(tr->screenXYs);
	free(tr->times);
}

void initEasingRecord(EasingRecord * er){
	er->TIME_SCALE=0.033;
	er->MAXIMUM_SPEED=10000;
	er->MINIMUM_SPEED_RATIO=0.001;
	er->CUTOFF_SPEED=DEFAULT_REFRESH_RATE;
	
	er->decelerateRate=g_config.DECELERATE;
	er->speed=0;
	er->startMoveTime=0;
	er->movedDistance=0;
	er->direction=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
    
    er->listener=nil;
}

void freeEasingRecord(EasingRecord * er){
	[er->direction release];
    [er->listener release];
    er->listener=nil;
}

void initZoomingRecord(ZoomingRecord * zr){
	zr->zoomToLevel=-1;
	zr->digitalZoomEndTime=0;
    zr->speed=0;
	zr->digitalZooming=FALSE;
	zr->zoomCenterXY=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
    
    zr->listener=nil;
}
	

void resetZoomingRecord(ZoomingRecord * zr){
	zr->zoomToLevel=-1;
	zr->digitalZoomEndTime=0;
    zr->speed=0;
	zr->digitalZooming=FALSE;
	zr->zoomCenterXY.x=0;
	zr->zoomCenterXY.y=0;
    
    [zr->listener release];
    zr->listener=nil;
}

void freeZoomingRecord(ZoomingRecord * zr){
	[zr->zoomCenterXY release];
    [zr->listener release];
    zr->listener=nil;
}


deCartaXYFloat * getDirection(float x0,float y0,float x1,float y1){
	float vecX=x0-x1;
	float vecY=y0-y1;
	float mag=(float)sqrt(vecX*vecX+vecY*vecY);
	if(mag==0) return [[[deCartaXYFloat alloc] initWithXf:0 andYf:0] autorelease];
	return [[[deCartaXYFloat alloc] initWithXf:vecX/mag andYf:vecY/mag] autorelease];
}

@interface deCartaMapView (GLViewPrivate)
- (void)configureFrame;
- (void)setContext:(EAGLContext *)newContext;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)pauseView;
- (void)resumeView;
- (void)initGLView;
- (void)deallocGLView;


@end

@interface deCartaMapView(Private)
-(void)initParams;
-(void)configureTileGridWithWidth:(int)w andHeight:(int)h;
-(void)resetEasingRecord:(EasingRecord *)er;
-(void)configureMapLayer;
-(deCartaXYFloat *) screenXYToScreenXYConv:(float)left top:(float)top;
-(void)rotateZFromOld:(deCartaXYFloat *)o toNew:(deCartaXYFloat *)n;
-(void)rotateX:(float)delXRotation;
-(deCartaXYDouble *)screenXYConvToMercXY:(float)convX convY:(float)convY zoom:(float)zoomLevel;
-(deCartaXYFloat *)mercXYToScreenXYConv:(deCartaXYDouble *)mercXY zoom:(float)zoomLevel;
-(BOOL)snapToInfoWindowAtX:(float)screenX y:(float)screenY;
-(NSArray *)snapToOverlay:(deCartaOverlay *)overlay atMerc:(deCartaXYDouble *)mercXY atX:(float)screenX y:(float)screenY;
-(void)convPoint:(CGPoint *)touchPointP;
-(deCartaXYFloat *)positionToScreenXYConv:(deCartaPosition *)pos;
-(deCartaPosition *)screenXYConvToPos:(float)sx y:(float)sy;
-(void)zoomTo:(int)inZ center:(deCartaXYFloat *)zoomCenterXYConv duration:(double)duration listener:(deCartaEventListener *)listener;
-(void)renderMap:(deCartaTileGridResponse *)resp;

-(void)drawOverlayItemOpenGL:(deCartaPin *)pin atX:(float)x y:(float)y;


-(void)zoomViewTo:(float)newZoomLevel atCenter:(deCartaXYFloat *)zoomCenterXY;
-(void)moveViewX:(float)left andY:(float)top;

-(void)drawFrame;

-(CGRect)getInfoWindowRect:(deCartaXYFloat *)screenXY;

-(void)longTouchTask:(id)param;
-(void)resetLongTouchTimer;
-(void)setupLongTouchTimer:(deCartaXYFloat *)xy0Conv;
@end


@implementation deCartaMapView (GLViewPrivate)
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [deCartaLogger debug:@"MapView layoutSubviews"];
	[self deleteFramebuffer];
	
	
	
	
}

- (void)configureFrame{
	//self.autoresizingMask |= (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
	UIScreen * mainScreen=[UIScreen mainScreen];
	CGRect applicationFrame=mainScreen.applicationFrame;
	CGRect bounds=mainScreen.bounds;
	[deCartaLogger debug:[NSString stringWithFormat:@"MapView configureFrame applicationFrame:%f|%f,bounds:%f|%f",
						 applicationFrame.size.width,applicationFrame.size.height,bounds.size.width,bounds.size.height]];
	//self.layer.frame=applicationFrame;
}	

- (void)setContext:(EAGLContext *)newContext
{
    if (_context != newContext)
    {
        [self deleteFramebuffer];
        
        [_context release];
        _context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}


- (void)setFramebuffer
{
    if (_context)
    {
        [EAGLContext setCurrentContext:_context];
        
        if (!_defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        
        glViewport(0, 0, _framebufferWidth, _framebufferHeight);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (_context)
    {
        [EAGLContext setCurrentContext:_context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        
        success = [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)createFramebuffer
{
    if (_context && !_defaultFramebuffer)
    {
        [deCartaLogger debug:@"MapView createFrameBuffer"];
		[self configureFrame];
		
		[EAGLContext setCurrentContext:_context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &_defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &_colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
        [deCartaLogger debug:[NSString stringWithFormat:@"MapView createFrameBuffer framebufferWidth:%d,framebufferHeight:%d,layer.width:%f,layer.height:%f",
							 _framebufferWidth,_framebufferHeight,self.layer.frame.size.width,self.layer.frame.size.height]];
        
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            [deCartaLogger warn:[NSString stringWithFormat:@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER)]];
		
		
		[self configureTileGridWithWidth:_framebufferWidth andHeight:_framebufferHeight];
    }
}

- (void)deleteFramebuffer
{
    if (_context)
    {
        [deCartaLogger debug:@"MapView deleteFrameBuffer"];
		
		[EAGLContext setCurrentContext:_context];
        
        if (_defaultFramebuffer)
        {
            glDeleteFramebuffers(1, &_defaultFramebuffer);
            _defaultFramebuffer = 0;
        }
        
        if (_colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &_colorRenderbuffer);
            _colorRenderbuffer = 0;
        }
    }
}

- (void)pauseView{
	[_displayLink setPaused:TRUE];
}

- (void)resumeView{
	[_displayLink setPaused:FALSE];
}

- (void)initGLView
{
	[deCartaLogger debug:@"MapView initGLView"];
	
	self.multipleTouchEnabled = YES;
	
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = TRUE;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									nil];
	
	EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if (!aContext)
        [deCartaLogger fatal:[NSString stringWithFormat:@"MapView initGLView Failed to create ES context"]];
    else if (![EAGLContext setCurrentContext:aContext])
        [deCartaLogger fatal:[NSString stringWithFormat:@"MapView initGLView Failed to set ES context current"]];
    
	[self setContext:aContext];
	[aContext release];
	
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    g_scale = 1.0f;
	
	if ([currSysVer compare:@"3.2" options:NSNumericSearch] != NSOrderedAscending){
		UIScreen * mainScreen=[UIScreen mainScreen];
		if ([mainScreen respondsToSelector:@selector(scale)]
			&& [self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			//[deCartaLogger debug:@"MapView initGLView get scale and setContentScaleFactor"];
			g_scale = [mainScreen scale];
			[self setContentScaleFactor: g_scale];
		}else{
			if(![mainScreen respondsToSelector:@selector(scale)])
				[deCartaLogger warn:@"MapView initGLView UIScreen doesn't respond to scale"];
			if(![self respondsToSelector:@selector(setContentScaleFactor:)])
				[deCartaLogger warn:@"MapView initGLView GLView doesn't respond to setContentScaleFactor"];
		}
		
	}
	[deCartaLogger info:[NSString stringWithFormat:@"MapView initGLView system ver:%@,g_scale:%f",currSysVer,g_scale]];
	
	
	[self setFramebuffer];
    
    _animating = FALSE;
    _displayLink = nil;
    
}


- (void)deallocGLView
{
    [deCartaLogger debug:@"MapView deallocGLView"];
	[self deleteFramebuffer];    
    [_context release];
    [_displayLink release];
    [super dealloc];
}

@end



@implementation deCartaMapView(Private)

-(void) initParams{

#if !(TARGET_IPHONE_SIMULATOR)
	[deCartaLogger info:@"MapView initParams !(TARGET_IPHONE_SIMULATOR):TRUE"];
#else
	[deCartaLogger info:@"MapView initParams !(TARGET_IPHONE_SIMULATOR):FALSE"];
#endif
	
	
	[deCartaConfig printConfig];	
	
	[deCartaUtil initUtil];
	
	//instantiate variables
	_eventListeners=[[NSMutableDictionary alloc] init];
	
	_overlays=[[NSMutableArray alloc] init];
	_shapes=[[NSMutableArray alloc] init];
	_infoWindow=[[deCartaInfoWindow getInfoWindowInstance] retain];
	
	_gridSize = [[deCartaXYInteger alloc] initWithXi:0 andYi:0];
	_displaySize = [[deCartaXYInteger alloc] initWithXi:0 andYi:0];
	_offset= [[deCartaXYFloat alloc] initWithXf:0 andYf:0];
    _radiusX=0;
    _radiusY=0;
    _panDirection= [[deCartaXYInteger alloc] initWithXi:1 andYi:1];
	
	_mapLayers=[[NSMutableArray alloc] init];
	
	_tileImages=[[deCartaDictionary alloc] initWithSize:MAX_TILE_IMAGE_DEF andDelFunc:nil];
	_tileTextureRefs=[[deCartaDictionary alloc] initWithSize:MAX_TILE_TEXTURE_REF_DEF andDelFunc:removeTexRef];
	_iconPool=[[deCartaDictionary alloc] initWithSize:MAX_ICON_SIZE andDelFunc:removeTexRef];
    _clusterTextPool=[[deCartaDictionary alloc] initWithSize:MAX_CLUSTER_TEXT_SIZE andDelFunc:removeTexRef];
	
	_mapType=STREET_MAP_TYPE;
	_centerXYZ=[[deCartaXYZ alloc] initWithX:0 andY:0 andZ:0];
	_centerXY=nil;
	_centerDelta=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	_fadingStartTime=0;
	
	_zoomLevel=13;
	_zooming=NO;
	
	initZoomingRecord(&_zoomingRecord);
		
	_lastCenterConv=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	_multiTouch=NO;
	_lastTouchConv = [[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	_lastTouch=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	
	initTouchRecord(&_touchRecord1, 5);
	initEasingRecord(&_easingRecord);
	
	_infoWindowClicked=NO;
	_longClicked=NO;
    _lastTouchDownTime=0;
	_lastTouchDown=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	_maxMoveFromTouchDown=0;
	_lastTouchUpTime=0;
	_lastTouchUp=[[deCartaXYFloat alloc] initWithXf:0 andYf:0];
	_lastDistConv=0;
	_lastDirection=nil;
	_lastTouchY = nil;
	_touchMode=0;
    
    _longTouchTimer=nil;
    _longTouchLock=[[NSObject alloc] init];
	
	initTouchRecord(&_touchRecord2, 10);
	
	_lastZoomLevel=-1;
    _lastXRotation=0;
    _lastZRotation=0;
	
	_mapMode=[[deCartaMapMode alloc] init];
	
	_mapPreference.routeId=nil;
	_mapPreference.realTimeTraffic=NO;
	
	_drawingLock=[[NSObject alloc] init];
    _touching=FALSE;
    _touchingLock=[[NSCondition alloc] init];
    _movingLock=[[NSCondition alloc] init];
	_drawingTiles=[[NSMutableArray alloc] init];
	
	_compass=nil;
	
	_tileThreadPool=[[deCartaTileThreadPool alloc] initWithMapView:self];
		
	//constructor
	for(int i=0;i<NUM_OF_MAPLAYER_TYPE;i++){
		deCartaMapLayerProperty * mapLayerProperty=[deCartaMapLayerProperty getInstance:i];
		deCartaMapLayer * mapLayer=[[[deCartaMapLayer alloc] initWithMapLayerProperty:mapLayerProperty] autorelease];
		[_mapLayers addObject:mapLayer];
	}
	[self configureMapLayer];
	[deCartaMapLayerProperty getInstance:SATELLITE].templateSeedTileUrl=
	[NSString stringWithFormat:@"http://www.globexplorer.com/tiles/decarta?key=%@&LL=37.786505,-122.39862&ZOOM=9&CACHEABLE=true&WIDTH=%d&HEIGHT=%d&FORMAT=PNG&N=0&E=0",
	 g_config.SATELLITE_KEY,g_config.TILE_SIZE,g_config.TILE_SIZE];
	
	[_tileThreadPool startAllThreads];
	
	if(g_config.COMPASS_PLACE_LOCATION>-1 && g_config.COMPASS_PLACE_LOCATION<=3){
		_compass=[[deCartaCompass alloc] init];
		_compass.compassLocation=g_config.COMPASS_PLACE_LOCATION;
		
	}
	
	[self initGLView];
	//[self configureTileGridWithWidth:[self getWidth] andHeight:[self getHeight]];
	
}

-(void)resetEasingRecord:(EasingRecord *)er{
	er->decelerateRate=g_config.DECELERATE;
	er->speed=0;
	er->startMoveTime=0;
	er->movedDistance=0;
	er->direction.x=0;
	er->direction.y=0;
    
    [er->listener release];
    er->listener=nil;
    
    [_movingLock lock];
    [_movingLock signal];
    [_movingLock unlock];
    
}

-(void)configureTileGridWithWidth:(int)w andHeight:(int)h
{
	_displaySize.x=w;
	_displaySize.y=h;
	
	int tileSize=g_config.TILE_SIZE;
	
	_gridSize.x=(int)ceil(_displaySize.x/(float)tileSize) + 2;
	if(_gridSize.x%2==0) _gridSize.x++;
	_gridSize.y=(int) ceil(_displaySize.y/(float)tileSize) + 2;
	if(_gridSize.y%2==0) _gridSize.y++;
	
	_offset.x = (float)(_displaySize.x - (tileSize * _gridSize.x)) / 2;
	_offset.y = (float)(_displaySize.y - (tileSize * _gridSize.y)) / 2;
	[deCartaLogger info:[NSString stringWithFormat:@"MapView configureTileGrid displaySize:%@,offset:%@,gridSize:%@",_displaySize,_offset,_gridSize]];
	
	[_mapMode configViewDepth:_displaySize];
	[_mapMode configViewSize:_displaySize];
	
	
}

-(void)configureMapLayer{
	for(int i=0;i<[_mapLayers count];i++){
		deCartaMapLayer * mapLayer=[_mapLayers objectAtIndex:i];
		deCartaMapLayerProperty * mapLayerProperty=mapLayer.mapLayerProperty; 
		mapLayer.visible=MapType_MapLayer_Visibility[_mapType][mapLayerProperty.mapLayerType];
		mapLayerProperty.format=MapLayer_Format[mapLayerProperty.mapLayerType];
		
	}
	
	
}

-(deCartaXYFloat *) screenXYToScreenXYConv:(float)left top:(float)top{
	if(_mapMode.zRotation==0 && _mapMode.xRotation==0){
		return [[[deCartaXYFloat alloc] initWithXf:left andYf:top] autorelease];
	}
	
	left-=_displaySize.x/2;
	top-=_displaySize.y/2;
	float cosX=_mapMode.cosX;
	float sinX=_mapMode.sinX;
	float y0=(_mapMode.middleZ*top)/(_mapMode.nearZ*_mapMode.scale*cosX-top*_mapMode.scale*sinX);
	float x0=(left*_mapMode.middleZ+left*_mapMode.scale*y0*sinX)/(_mapMode.nearZ*_mapMode.scale);
	float cosZ=_mapMode.cosZ;
	float sinZ=-_mapMode.sinZ;
	float x=cosZ*x0-sinZ*y0;
	float y=sinZ*x0+cosZ*y0;
	x+=_displaySize.x/2;
	y+=_displaySize.y/2;
	
	return [[[deCartaXYFloat alloc] initWithXf:x andYf:y] autorelease];
}


-(void)rotateZFromOld:(deCartaXYFloat *)o toNew:(deCartaXYFloat *)n{
	if((o.x==0 && o.y==0) || (n.x==0 && n.y==0)) return;
	
	double sinL=(o.x*n.y-o.y*n.x);
	double asinL=asin(sinL)*180/M_PI;
	
	
	if(ABS(asinL)>ABNORMAL_ZROTATION){
		[deCartaLogger warn:[NSString stringWithFormat:@"MapView rotateZ asin abnormal:%f",asinL]];
		
		return;
	}
	
	float r=_mapMode.zRotation;
	r+=(float)asinL;
	r=(((int)r+180)%360+360)%360-180+(r-(int)r);
	
	[_mapMode setZRotation:r withDisplaySize:_displaySize];
	
}

-(void)rotateX:(float)delXRotation{
	
	float r=_mapMode.xRotation;
	r+=(delXRotation);
	if(r>0){
		r=0;
	}
	else if(r<MAP_TILT_MIN){
		r=MAP_TILT_MIN;
	}
	[_mapMode setXRotation:r withDisplaySize:_displaySize];
}


-(deCartaXYDouble *)screenXYConvToMercXY:(float)convX convY:(float)convY zoom:(float)zoomLevel{
	double scale2=pow(2,self.zoomLevel-_centerXYZ.z);
	double x=_centerXY.x*scale2-_displaySize.x/2+convX;
	double y=_centerXY.y*scale2+_displaySize.y/2-convY;
	double scale1=pow(2,zoomLevel-self.zoomLevel);
	return [[[deCartaXYDouble alloc] initWithXd:x*scale1 andYd:y*scale1] autorelease];
}

-(deCartaXYFloat *)mercXYToScreenXYConv:(deCartaXYDouble *)mercXY zoom:(float)zoomLevel{
	double scale1=pow(2,self.zoomLevel-zoomLevel);
	double scale2=pow(2,self.zoomLevel-_centerXYZ.z);
	double x=mercXY.x*scale1-_centerXY.x*scale2+_displaySize.x/2;
	double y=_centerXY.y*scale2+_displaySize.y/2-mercXY.y*scale1;
	return [[[deCartaXYFloat alloc] initWithXf:x andYf:y] autorelease];
}

-(NSArray *) snapToOverlay:(deCartaOverlay *)overlay atMerc:(deCartaXYDouble *)mercXY atX:(float)screenX y:(float)screenY{
    NSArray * touchTiles=[deCartaUtil getTouchTilesAtMerc:mercXY z:_centerXYZ.z radius:TOUCH_RADIUS];
    NSArray * clusters=[overlay getVisiblePinsAtZ:_centerXYZ.z tiles:touchTiles];
    int size=[clusters count];
    if(size==0) return nil;
    
    int start= random()%size;
    float cosZ=_mapMode.cosZ;
    float sinZ=_mapMode.sinZ;
    float buffer=SNAP_BUFFER*g_scale;
    for(int i=0;i<size;i++){
        NSArray * cluster=[clusters objectAtIndex:((i+start)%size)];
        if([cluster count]==0){
            [deCartaLogger warn:@"ItemizedOverlay onSnapToItem cluster is empty"];
        }
        deCartaPin * pin=nil;
        for(int ii=0;ii<[cluster count];ii++){
            deCartaPin * pinL=[cluster objectAtIndex:ii];
            if(pinL.icon.image!=nil && pinL.mercXY!=nil && pinL.visible){
                pin=pinL;
                break;
            }
        }
        if(pin==nil) continue;
        
        deCartaXYFloat * xyConv=[self mercXYToScreenXYConv:pin.mercXY zoom:ZOOM_LEVEL];
        float x1=xyConv.x-_displaySize.x/2;
        float y1=xyConv.y-_displaySize.y/2;
        float x2=cosZ*x1-sinZ*y1;
        float y2=sinZ*x1+cosZ*y1;
        y2*=(_mapMode.scale);
        x2*=(_mapMode.scale);
        float sinX=_mapMode.sinX;
        float cosX=_mapMode.cosX;
        float z=y2*sinX+_mapMode.middleZ;
        y2*=(cosX);
        
        deCartaRotationTilt * rt=pin.rotationTilt;
        float cosT=rt.cosT;
        float sinT=rt.sinT;
        if(rt.tiltRelativeTo==TILT_RELATIVE_TO_MAP){
            cosT=rt.cosT*_mapMode.cosX-rt.sinT*_mapMode.sinX;
            sinT=rt.sinT*_mapMode.cosX+rt.cosT*_mapMode.sinX;
        }
        float cosR=rt.cosR;
        float sinR=rt.sinR;
        if(rt.rotateRelativeTo==ROTATE_RELATIVE_TO_MAP){
            cosR=rt.cosR*_mapMode.cosZ-rt.sinR*_mapMode.sinZ;
            sinR=rt.sinR*_mapMode.cosZ+rt.cosR*_mapMode.sinZ;
        }
        float xt=(screenX-_displaySize.x/2);
        float yt=(screenY-_displaySize.y/2);
        float yd=(yt*z-y2*_mapMode.nearZ)/(_mapMode.nearZ*cosT-yt*sinT);
        float xd=xt*(z+yd*sinT)/_mapMode.nearZ-x2;
        
        float xTouch2=cosR*xd+sinR*yd;
        float yTouch2=-sinR*xd+cosR*yd;
        
        float scaleToM=_mapMode.middleZ/(float)_mapMode.nearZ;
        //yTouch2/=_mapMode.scale;
        //xTouch2/=_mapMode.scale;
        yTouch2/=scaleToM;
        xTouch2/=scaleToM;
        
        deCartaXYInteger * pinSize=pin.icon.size;
        deCartaXYInteger * offset=pin.icon.offset;
        if(xTouch2<-offset.x+pinSize.x+buffer && xTouch2>-offset.x-buffer &&
           yTouch2<-offset.y+pinSize.y+buffer && yTouch2>-offset.y-buffer){
            return cluster;
        }
    }
    return nil;
}

-(BOOL)snapToInfoWindowAtX:(float)screenX y:(float)screenY{
	float scaleToM=_mapMode.middleZ/(float)_mapMode.nearZ;
    
    deCartaXYFloat * xyConv=[self mercXYToScreenXYConv:_infoWindow.mercXY zoom:ZOOM_LEVEL];
	float x1=xyConv.x-_displaySize.x/2;
	float y1=xyConv.y-_displaySize.y/2;
	float cosZ=_mapMode.cosZ;
	float sinZ=_mapMode.sinZ;
	float x2=cosZ*x1-sinZ*y1;
	float y2=sinZ*x1+cosZ*y1;
	y2*=(_mapMode.scale);
	x2*=(_mapMode.scale);
	float sinX=_mapMode.sinX;
	float cosX=_mapMode.cosX;
	float z=y2*sinX+_mapMode.middleZ;
	y2*=(cosX);
	
	deCartaRotationTilt * rt=_infoWindow.offsetRotationTilt;
	float cosR=rt.cosR;
	float sinR=rt.sinR;
	if(rt.rotateRelativeTo ==ROTATE_RELATIVE_TO_MAP){
		cosR=rt.cosR*_mapMode.cosZ-rt.sinR*_mapMode.sinZ;
		sinR=rt.sinR*_mapMode.cosZ+rt.cosR*_mapMode.sinZ;
	}
	float xOff=-_infoWindow.offset.x;
	float yOff=-_infoWindow.offset.y;
	float xOff2=cosR*xOff-sinR*yOff;
	float yOff2=sinR*xOff+cosR*yOff;
	//xOff2*=(_mapMode.scale);
	//yOff2*=(_mapMode.scale);
    xOff2*=scaleToM;
    yOff2*=scaleToM;
	
	float cosT=rt.cosT;
	float sinT=rt.sinT;
	if(rt.tiltRelativeTo==TILT_RELATIVE_TO_MAP){
		cosT=rt.cosT*_mapMode.cosX-rt.sinT*_mapMode.sinX;
		sinT=rt.sinT*_mapMode.cosX+rt.cosT*_mapMode.sinX;
	}
	z+=yOff2*sinT;
	y2+=yOff2*cosT;
	x2+=xOff2;
	
	float yTouch=(screenY-_displaySize.y/2)*z/_mapMode.nearZ;
	float xTouch=(screenX-_displaySize.x/2)*z/_mapMode.nearZ;
	yTouch-=y2;
	xTouch-=x2;
	//yTouch/=_mapMode.scale;
	//xTouch/=_mapMode.scale;
    yTouch/=scaleToM;
    xTouch/=scaleToM;
	
	CGRect rect=[self getInfoWindowRect:[[[deCartaXYFloat alloc] initWithXf:0 andYf:0] autorelease]];
	if(xTouch>rect.origin.x && xTouch<rect.origin.x+rect.size.width && yTouch>rect.origin.y && yTouch<rect.origin.y+rect.size.height){
		return TRUE;
	}
	
	return FALSE;
}

-(void)convPoint:(CGPoint *)touchPointP{
	float scale=g_scale;
	touchPointP->x=touchPointP->x*scale;
	touchPointP->y=touchPointP->y*scale;
}

- (void) touchesBegan : (NSSet *) touches withEvent : (UIEvent *) event
{
	//[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesBegan part count:%d,all count:%d",[touches count],[[event allTouches] count]]];
	
	if(!_centerXY) return;
	NSSet * allTouches=[event allTouches];
	int pCount=[allTouches count];
	
	UITouch * touch0=[[allTouches allObjects] objectAtIndex:0];
	CGPoint p0=[touch0 locationInView:self];
	[self convPoint:&p0];
	
	deCartaXYFloat * xy0Conv=[self screenXYToScreenXYConv:p0.x top:p0.y];
	double time=[NSDate timeIntervalSinceReferenceDate];
	
	resetTouchRecord(&_touchRecord1);
	resetTouchRecord(&_touchRecord2);
	
	@synchronized(_drawingLock){
		[_mapMode resetXEasing];
		[_mapMode resetZEasing];
		[self resetEasingRecord:(&_easingRecord)];
		resetZoomingRecord(&_zoomingRecord);
	}
	
	_infoWindowClicked=FALSE;
	
    [self resetLongTouchTimer];
    _longClicked=FALSE;
    
	_multiTouch=FALSE;
	_lastDistConv=0;
	[_lastTouchY release];
	_lastTouchY=nil;
	[_lastDirection release];
	_lastDirection=nil;
	_touchMode=0;//zooming
	
	_lastZoomLevel=_zoomLevel;
	_lastXRotation=[_mapMode xRotation];
	_lastZRotation=[_mapMode zRotation];
	
	if(pCount==1){
		pushToTouchRecord(&_touchRecord1, time, xy0Conv.x, xy0Conv.y);
		
		_lastTouchDownTime=[NSDate timeIntervalSinceReferenceDate];
		_lastTouchDown.x=p0.x;
		_lastTouchDown.y=p0.y;
		_maxMoveFromTouchDown=0;
		
		_lastTouchConv.x = xy0Conv.x;
		_lastTouchConv.y = xy0Conv.y;
		_lastTouch.x=p0.x;
		_lastTouch.y=p0.y;
		
		if(_infoWindow.visible && _infoWindow.mercXY!=nil) {
			if([self snapToInfoWindowAtX:p0.x y:p0.y]){
				_infoWindowClicked=true;
				_infoWindow.backgroundColor=INFO_WINDOW_BACKGROUND_COLOR_CLICKED;
				[self refreshMap];
			}
			
		}
		
        if(!_infoWindowClicked){
            [self setupLongTouchTimer:xy0Conv];
        }
        
	}else if(pCount>1){
		_multiTouch=true;
	}
    
    [_touchingLock lock];
    _touching=TRUE;
    [_touchingLock unlock];
	
}

- (void) touchesMoved : (NSSet *) touches 
			withEvent : (UIEvent *) event
{
	//[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesMoved part count:%d,all count:%d",[touches count],[[event allTouches] count]]];
	
	if(!_centerXY) return;
	
	NSSet * allTouches=[event allTouches];
	int pCount=[allTouches count];
	UITouch * touch0=[[allTouches allObjects] objectAtIndex:0];
	CGPoint p0=[touch0 locationInView:self];
	[self convPoint:&p0];
	
    if(pCount>1){
        [self resetLongTouchTimer];
    }
    
	deCartaXYFloat * xy0Conv=[self screenXYToScreenXYConv:p0.x top:p0.y];
	double time=[NSDate timeIntervalSinceReferenceDate];
	if(!_multiTouch && pCount==1){
		@synchronized(_longTouchLock){
            if(_longClicked) return;
        }
        
		if(_infoWindowClicked){
			if([self snapToInfoWindowAtX:p0.x y:p0.y]){
				int oriColor=_infoWindow.backgroundColor;
				_infoWindow.backgroundColor=INFO_WINDOW_BACKGROUND_COLOR_CLICKED;
				if(oriColor!=_infoWindow.backgroundColor) [self refreshMap];
			}else{
				int oriColor=_infoWindow.backgroundColor;
				_infoWindow.backgroundColor=INFO_WINDOW_BACKGROUND_COLOR_UNCLICKED;
				if(oriColor!=INFO_WINDOW_BACKGROUND_COLOR_UNCLICKED) [self refreshMap];
			}
			return;
		}
		
		float moveFromTouchDownX=p0.x-_lastTouchDown.x;
		float moveFromTouchDownY=p0.y-_lastTouchDown.y;
		float moveFromTouchDown=moveFromTouchDownX*moveFromTouchDownX+moveFromTouchDownY*moveFromTouchDownY;
		if(moveFromTouchDown>_maxMoveFromTouchDown) _maxMoveFromTouchDown=moveFromTouchDown;
		if(_maxMoveFromTouchDown>SAME_POINT_MOVED_DISTANCE_MAX*g_scale*SAME_POINT_MOVED_DISTANCE_MAX*g_scale){
			[self resetLongTouchTimer];
		}
		
		deCartaXYFloat * draggingConv=[[[deCartaXYFloat alloc] initWithXf:0 andYf:0] autorelease];
		draggingConv.x = xy0Conv.x-_lastTouchConv.x;
		draggingConv.y = xy0Conv.y-_lastTouchConv.y;
		//Log.i("Moving","onTouchEvent dragging:"+dragging);
		if(ABS(p0.x-_lastTouch.x)+ABS(p0.y-_lastTouch.y)>ABNORMAL_DRAGGING_DIST*g_scale){
			[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesMoved dragging abruptly:%@",draggingConv]];
		}
		//else{
			pushToTouchRecord(&_touchRecord1, time, xy0Conv.x, xy0Conv.y);
			_lastTouchConv.x = xy0Conv.x;
			_lastTouchConv.y = xy0Conv.y;
			_lastTouch.x=p0.x;
			_lastTouch.y=p0.y;
			@synchronized(_drawingLock){
				[self moveViewX:draggingConv.x andY:draggingConv.y];
				[self resumeView];
			}
			
		//}
	}else if(pCount>1){
		_multiTouch=true;
		UITouch * touch1=[[allTouches allObjects] objectAtIndex:1];
		CGPoint p1=[touch1 locationInView:self];
		[self convPoint:&p1];
		pushToTouchRecord(&_touchRecord2, 0, p0.x, p0.y);
		pushToTouchRecord(&_touchRecord2, 0, p1.x, p1.y);
		
		if(_touchRecord2.size>=2*2){
			int touchModeL=0;//zooming
			
			int index=_touchRecord2.index;
			int start=(index-(_touchRecord2.size-1)+_touchRecord2.capacity)%_touchRecord2.capacity;
			float x0=_touchRecord2.screenXYs[index-1].x-_touchRecord2.screenXYs[start].x;
			float y0=_touchRecord2.screenXYs[index-1].y-_touchRecord2.screenXYs[start].y;
			float x1=_touchRecord2.screenXYs[index].x-_touchRecord2.screenXYs[start+1].x;
			float y1=_touchRecord2.screenXYs[index].y-_touchRecord2.screenXYs[start+1].y;
			float vx=_touchRecord2.screenXYs[start+1].x-_touchRecord2.screenXYs[start].x;
			float vy=_touchRecord2.screenXYs[start+1].y-_touchRecord2.screenXYs[start].y;
			
			
			double r0=sqrt(x0*x0+y0*y0);
			double r1=sqrt(x1*x1+y1*y1);
			if(r0==0 || r1==0){
				if(r0!=0 || r1!=0){
					double r=sqrt(vx*vx+vy*vy);
					if(ABS(x0*vx+y0*vy+x1*vx+y1*vy)/((r0+r1)*r)<Cos60){
						touchModeL=1;//rotating
					}
				}
			}
			else if((x0*x1+y0*y1)/(r0*r1)>Cos30){
				if(ABS(y0)/r0>Cos30 && ABS(y1)/r1>Cos30) 
					touchModeL=2;//tilt
			}
			else if((x0*x1+y0*y1)/(r0*r1)<-Cos30){
				double r=sqrt(vx*vx+vy*vy);
				if(ABS(x0*vx+y0*vy)/(r0*r)<Cos60 && ABS(x1*vx+y1*vy)/(r1*r)<Cos60){
					touchModeL=1;//rotating
				}
			}
			
			
			
			if(touchModeL!=_touchMode){
				_lastDistConv=0;
				[_lastDirection release];
				_lastDirection=nil;
				[_lastTouchY release];
				_lastTouchY=nil;
				_touchMode=touchModeL;
			}
		}
		if(_touchMode==0){//zooming
			deCartaXYFloat * xy1Conv=[self screenXYToScreenXYConv:p1.x top:p1.y];
			
			float distXConv=xy0Conv.x-xy1Conv.x;
			float distYConv=xy0Conv.y-xy1Conv.y;
			float distConv=(float)sqrt(distXConv*distXConv+distYConv*distYConv);
			if(distConv<MIN_PINCH_DISTANCE*g_scale) {
				_lastDistConv=0;
				return;
			}
			else if(_lastDistConv==0) {
				_lastCenterConv.x=(xy0Conv.x+xy1Conv.x)/2;
				_lastCenterConv.y=(xy0Conv.y+xy1Conv.y)/2;
				_lastDistConv=distConv;
			}
			else if(distConv!=_lastDistConv){
				float centerDistXConv=ABS((xy0Conv.x+xy1Conv.x)/2-_lastCenterConv.x);
				float centerDistYConv=ABS((xy0Conv.y+xy1Conv.y)/2-_lastCenterConv.y);
				if((centerDistXConv+centerDistYConv)>ABNORMAL_PINCH_CENTER_DIST*g_scale){
					_lastDistConv=0;
					[deCartaLogger warn:[NSString stringWithFormat:@"MapView touchesMoved pinch abnormal center dist:%f:",(centerDistXConv+centerDistYConv)]];
				}else{
					_lastCenterConv.x=(xy0Conv.x+xy1Conv.x)/2;
					_lastCenterConv.y=(xy0Conv.y+xy1Conv.y)/2;
					float newZoomLevel=_zoomLevel+(float)(log(distConv/_lastDistConv)/log(2));
					_lastDistConv=distConv;
					@synchronized(_drawingLock){
						@try{
							[self zoomViewTo:newZoomLevel atCenter:_lastCenterConv];
							[self resumeView];
						}@catch(NSException * e){
							[deCartaLogger warn:[NSString stringWithFormat:@"MapView touchesMoved zoomView e.name:%@,e.reason:%@",[e name],[e reason]]];
							return;
						}
					}
					
				}
			}
		}else if(_touchMode==1){//rotating
			float distX=p1.x-p0.x;
			float distY=p1.y-p0.y;
			float dist=(float)sqrt(distX*distX+distY*distY);
			if(dist<MIN_ROTATE_DISTANCE*g_scale) {
				[_lastDirection release];
				_lastDirection=nil;
				return;
			}
			if(_lastDirection==nil){
				_lastDirection=[getDirection(p0.x,p0.y,p1.x,p1.y) retain];
			}else{
				@synchronized(_drawingLock){
					deCartaXYFloat * newDirection=getDirection(p0.x,p0.y,p1.x,p1.y);
					[self rotateZFromOld:_lastDirection toNew:newDirection];
					[_lastDirection release];
					_lastDirection=[newDirection retain];
					
					[self resumeView];
				}
				
			}			
		}else if(_touchMode==2){//tilting
			if(_lastTouchY==nil){
				_lastTouchY=[[deCartaXYFloat alloc] initWithXf:p0.y andYf:p1.y];
			}else{
				float delY0=p0.y-_lastTouchY.x;
				float delY1=p1.y-_lastTouchY.y;
				_lastTouchY.x=p0.y;
				_lastTouchY.y=p1.y;
				if(delY0*delY1>0){
					@synchronized(_drawingLock){
						float delX=(delY0+delY1)/2*MAP_TILT_MIN/(XROTATION_YDIST*g_scale);
						[self rotateX:delX]; 
						
						[self resumeView];
					}
					
				}
			}			
		}
		return;
		
	}else if(_multiTouch && pCount==1){
		_lastDistConv=0;
		[_lastDirection release];
		_lastDirection=nil;
		[_lastTouchY release];
		_lastTouchY=nil;
		resetTouchRecord(&_touchRecord2);
	}
	
}
//------------------------------------------------------------------------------
- (void) touchesEnded : (NSSet *) touches 
			withEvent : (UIEvent *) event 
{
	//[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesEnded part count:%d,all count:%d",[touches count],[[event allTouches] count]]];
	
	if(!_centerXY) return;
    NSSet * allTouches=[event allTouches];
	int pCount=[allTouches count];
	UITouch * touch0=[[allTouches allObjects] objectAtIndex:0];
	CGPoint p0=[touch0 locationInView:self];
	[self convPoint:&p0];
	
	//	deCartaXYFloat * xy0Conv=screenXYToScreenXYConv(p0.x, p0.y);
	double time=[NSDate timeIntervalSinceReferenceDate];
	
    [self resetLongTouchTimer];
    
	if(pCount>1 && pCount>[touches count]) return;
    
	if(!_multiTouch && pCount==1){
		deCartaXYFloat * xy0Conv=[self screenXYToScreenXYConv:p0.x top:p0.y];
		
		@synchronized(_longTouchLock)
        {
            if(_longClicked){
                [_touchingLock lock];
                _touching=FALSE;
                [_touchingLock signal];
                [_touchingLock unlock];
                
                return ;
            } 
        }
        
		double touchUpTime=time;
		deCartaPosition * position=[self screenXYConvToPos:xy0Conv.x y:xy0Conv.y];
				_infoWindow.backgroundColor=INFO_WINDOW_BACKGROUND_COLOR_UNCLICKED;
		
		if(_lastTouchDownTime!=0 && (touchUpTime-_lastTouchDownTime)<CLICK_DOWN_UP_TIME_MAX
		   && (ABS(p0.x-_lastTouchDown.x)+ABS(p0.y-_lastTouchDown.y))<SAME_POINT_MOVED_DISTANCE_MAX*g_scale){
			
			if(_compass!=nil && _compass.visible){
				
				deCartaXYFloat * sxy=[[[deCartaXYFloat alloc] initWithXf:p0.x andYf:p0.y] autorelease];
				if([_compass snapTo:sxy displaySize:_displaySize]){
					[self rotateXToDegree:0];
					[self rotateZToDegree:0];
					
					[_compass executeEventListeners:TOUCH withParam:nil];
					
                    [_touchingLock lock];
                    _touching=FALSE;
                    [_touchingLock signal];
                    [_touchingLock unlock];
                    return;
				}
			}
		}
		
		if(_infoWindowClicked) {
			if([self snapToInfoWindowAtX:p0.x y:p0.y]){
				[_infoWindow executeEventListeners:TOUCH withParam:nil];
                _infoWindowClicked=false;
            }
            [self refreshMap];
            
            [_touchingLock lock];
            _touching=FALSE;
            [_touchingLock signal];
            [_touchingLock unlock];
            
            return;
		}
		
		if(_lastTouchDownTime!=0 && (touchUpTime-_lastTouchDownTime)<CLICK_DOWN_UP_TIME_MAX
		   && (ABS(p0.x-_lastTouchDown.x)+ABS(p0.y-_lastTouchDown.y))<SAME_POINT_MOVED_DISTANCE_MAX*g_scale){
			NSArray * cluster=nil;
			int size=[_overlays count];
			if(size>0){
				@synchronized(_drawingLock){
					
					int start=random()%size;
					deCartaXYDouble * mercXY=[self screenXYConvToMercXY:xy0Conv.x convY:xy0Conv.y zoom:_centerXYZ.z]; 
					for(int i=0;i<size;i++){
						deCartaOverlay * overlay=[_overlays objectAtIndex:(i+start)%size];
						cluster=[self snapToOverlay:overlay atMerc:mercXY atX:p0.x y:p0.y];
                        if(cluster!=nil) {
							break;
						}
					}
					
				}
			}
			
			if(cluster!=nil){
				if([cluster count]==0){
                    [deCartaLogger warn:@"MapView touchesEnded cluster empty"];
                }
                NSMutableArray * visiblePins=[[[NSMutableArray alloc] init] autorelease];
                for(int ii=0;ii<[cluster count];ii++){
                    deCartaPin * pinL=[cluster objectAtIndex:ii];
                    if(pinL.icon.image!=nil && pinL.mercXY!=nil && pinL.visible){
                        [visiblePins addObject:pinL];
                    }
                }
                if([visiblePins count]>0){
                    deCartaOverlay * overlay=[[visiblePins objectAtIndex:0] ownerOverlay];
                    if(overlay.clustering && [visiblePins count]>1){
                        if(overlay.clusterTouchEventListener!=nil){
                            (overlay.clusterTouchEventListener.callback)(nil,visiblePins);
                        }
                    }else{
                        deCartaPin * pin=[visiblePins objectAtIndex:random()%[visiblePins count]];
                        [pin executeEventListeners:TOUCH withParam:nil];
                    }
                }
				
			}else{
				_infoWindow.visible=false;
				[self executeEventListeners:TOUCH withParam:position];
				
				if(_lastTouchUpTime!=0 && (touchUpTime-_lastTouchUpTime)<DOUBLE_CLICK_INTERVAL_TIME_MAX
				   && (ABS(p0.x-_lastTouchUp.x)+ABS(p0.y-_lastTouchUp.y))<SAME_POINT_MOVED_DISTANCE_MAX*g_scale){
					_lastTouchUp.x=0;
					_lastTouchUp.y=0;
					_lastTouchUpTime=0;
					[self executeEventListeners:DOUBLECLICK withParam:position];
				}else{
					_lastTouchUp.x=p0.x;
					_lastTouchUp.y=p0.y;
					_lastTouchUpTime=touchUpTime;
				}
			}	        				
			
			[self refreshMap];
						
						
		}else{
			if(g_config.DECELERATE>0 && _touchRecord1.size>=2){
				float xDist=_touchRecord1.screenXYs[_touchRecord1.index].x-_touchRecord1.screenXYs[(_touchRecord1.index-(_touchRecord1.size-1)+_touchRecord1.capacity)%_touchRecord1.capacity].x;
				float yDist=_touchRecord1.screenXYs[_touchRecord1.index].y-_touchRecord1.screenXYs[(_touchRecord1.index-(_touchRecord1.size-1)+_touchRecord1.capacity)%_touchRecord1.capacity].y;
				double s=sqrt(xDist*xDist+yDist*yDist);
				double timeInterval=_touchRecord1.times[_touchRecord1.index]-_touchRecord1.times[(_touchRecord1.index-(_touchRecord1.size-1)+_touchRecord1.capacity)%_touchRecord1.capacity];
				@synchronized(_drawingLock){
					_easingRecord.speed=s/timeInterval;
					if(_easingRecord.speed>_easingRecord.MAXIMUM_SPEED*g_scale){
						[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesEnded easing too high speed:%f,s:%f,timeInterval:%f",_easingRecord.speed,s,timeInterval]];
						_easingRecord.speed=_easingRecord.MAXIMUM_SPEED*g_scale;
					}
					//[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesEnded easing speed:%f,s:%f,timeInterval:%f",_easingRecord.speed,s,timeInterval]];
					
					_easingRecord.startMoveTime=touchUpTime;
					_easingRecord.direction.x=(float)(xDist/s);
					_easingRecord.direction.y=(float)(yDist/s);
					_easingRecord.movedDistance=0;
                    
                    [_easingRecord.listener release];
                    _easingRecord.listener=nil;
					[self resumeView];
				}
				
				
			}
			if(g_config.DECELERATE<=0 || _easingRecord.speed<=0){
				deCartaPosition * center;
				@synchronized(_drawingLock){
					[self resetEasingRecord:(&_easingRecord)];
					center=[self getCenterPosition];
					[self resumeView];
				}
				
				[self executeEventListeners:MOVEEND withParam:center];
			}
			
		}
	}else if(_multiTouch){
		if(!g_config.SNAP_TO_CLOSEST_ZOOMLEVEL){
			if(_lastZoomLevel!=_zoomLevel){
				[self executeEventListeners:ZOOMEND withParam:[NSNumber numberWithFloat:_zoomLevel]];
			}
		}
        //else if(_lastDistConv!=0){
        else if(round(_zoomLevel)!=_zoomLevel){
			@synchronized(_drawingLock){
				_zoomingRecord.digitalZooming=TRUE;
				int newZoomLevel=round(_zoomLevel);
				_zoomingRecord.zoomToLevel=newZoomLevel;
				_zoomingRecord.digitalZoomEndTime=[NSDate timeIntervalSinceReferenceDate]+DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(newZoomLevel-_zoomLevel);
                _zoomingRecord.speed=1/DIGITAL_ZOOMING_TIME_PER_LEVEL*(newZoomLevel>_zoomLevel?1:-1);
				_zoomingRecord.zoomCenterXY.x=_lastCenterConv.x;
				_zoomingRecord.zoomCenterXY.y=_lastCenterConv.y;
                [_zoomingRecord.listener release];
                _zoomingRecord.listener=nil;
				[self resumeView];
			}
			
		}
		
		if(_lastZRotation!=[_mapMode zRotation]){
			[self executeEventListeners:ROTATEEND withParam:[NSNumber numberWithInt:_mapMode.zRotation]];
		}
		
		if(_lastXRotation!=[_mapMode xRotation]){
			[self executeEventListeners:TILTEND withParam:[NSNumber numberWithInt:_mapMode.xRotation]];
		}
	}
    
    [_touchingLock lock];
    _touching=FALSE;
    [_touchingLock signal];
    [_touchingLock unlock];
}

- (void) touchesCancelled : (NSSet *) touches 
				withEvent : (UIEvent *) event
{
	[deCartaLogger debug:[NSString stringWithFormat:@"MapView touchesCancelled part count:%d,all count:%d",[touches count],[[event allTouches] count]]];
	
	if(!_centerXY) return;
    
    [self resetLongTouchTimer];
    
    [_touchingLock lock];
    _touching=FALSE;
    [_touchingLock signal];
    [_touchingLock unlock];
	
}

	 
	
-(deCartaXYFloat *)positionToScreenXYConv:(deCartaPosition *)pos{
	deCartaXYDouble * mercXY=[deCartaUtil posToMercPix:pos atZoom:_zoomLevel];
	return [self mercXYToScreenXYConv:mercXY zoom:_zoomLevel];
}

-(deCartaPosition *)screenXYConvToPos:(float)sx y:(float)sy{
	deCartaXYDouble * xy=[self screenXYConvToMercXY:sx convY:sy zoom:_zoomLevel];
	return [deCartaUtil mercPixToPos:xy atZoom:_zoomLevel];
}

-(void)zoomTo:(int)inZ center:(deCartaXYFloat *)zoomCenterXYConv duration:(double)duration listener:(deCartaEventListener *)listener{
	@synchronized(_drawingLock){
		float zDif=inZ-_zoomLevel;
        if(zDif!=0 && duration==0){
            [deCartaLogger warn:@"MapView zoomTo:center:duration:listener inZ!=_zoomLevel && duration==0"];
            return;
        }
        
        _zoomingRecord.digitalZooming=true;
		_zoomingRecord.digitalZoomEndTime=[NSDate timeIntervalSinceReferenceDate]+duration;
        _zoomingRecord.speed=(duration==0)?0:zDif/duration;
		_zoomingRecord.zoomToLevel=inZ;
		_zoomingRecord.zoomCenterXY.x=zoomCenterXYConv.x;
		_zoomingRecord.zoomCenterXY.y=zoomCenterXYConv.y;
        
        [_zoomingRecord.listener release];
        _zoomingRecord.listener=[listener retain];
		
		[self resumeView];
	}
	
}


-(void)renderMap:(deCartaTileGridResponse *)resp{
	[_centerXY release];
	_centerXY=[[deCartaXYDouble alloc] initWithXd:resp.centerXY.x andYd:resp.centerXY.y];
	_centerXYZ.x=resp.centerXYZ.x;
	_centerXYZ.y=resp.centerXYZ.y;
	_centerXYZ.z=resp.centerXYZ.z;
	_centerDelta.x=resp.fixedGridPixelOffset.x;
	_centerDelta.y=resp.fixedGridPixelOffset.y;
	_radiusX=[resp.radiusY toMeters] * _displaySize.x/g_config.TILE_SIZE;
	_radiusY=[resp.radiusY toMeters] * _displaySize.y/g_config.TILE_SIZE;
	
	for(int i=0;i<[_mapLayers count];i++){
		deCartaMapLayer * layer=[_mapLayers objectAtIndex:i];
		layer.mainLayerDrawPercent=0;
	}
	
}

- (void) drawOverlayItemOpenGL:(deCartaPin *)pin atX:(float)x y:(float)y{
	
	unsigned int textureRef=0;
	deCartaIcon * icon=pin.icon;
	deCartaXYInteger * size=icon.size;
	deCartaXYInteger * offsetL=icon.offset;
	int bmSizeX=[deCartaUtil getPower2:size.x];
	int bmSizeY=[deCartaUtil getPower2:size.y];
	deCartaXYInteger * sizePower2=[[[deCartaXYInteger alloc] initWithXi:bmSizeX andYi:bmSizeY] autorelease];
	if([_iconPool objectForKey:icon]){
		textureRef=[(NSNumber *)[_iconPool objectForKey:icon] unsignedIntValue];
	}else{
		glGenTextures(1, &textureRef);
		glBindTexture(GL_TEXTURE_2D, textureRef);
		
		@try{
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);// GL_NEAREST);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);// GL_NEAREST);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			BOOL success=[deCartaImageUtil image2Texture:icon.image texRef:textureRef format:RGBA size:size sizePower2:sizePower2];
			if(!success){
				[deCartaLogger warn:[NSString stringWithFormat:@"MapView drawOverlayItemOpenGL texture failed:%d",textureRef]];
				glDeleteTextures(1, &textureRef);
				textureRef=0;
				return;
			}else {
				[_iconPool setObject:[NSNumber numberWithUnsignedInt:textureRef] forKey:icon];
				//[deCartaLogger debug:[NSString stringWithFormat:@"MapView drawOverlayItemOpenGL put texture:%d",textureRef]];
			}
			
		}@catch(NSException * e){
			[deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame drawOverlayItemOpenGL texture exception:%d",textureRef]];
			glDeleteTextures(1, &textureRef);
			textureRef=0;
		}
				
	}
	if(textureRef==0) return;
	
	glBindTexture(GL_TEXTURE_2D, textureRef);
	
	x-=offsetL.x;
	y-=offsetL.y;
	mVertexBuffer[0]=x;
	mVertexBuffer[1]=y;
	mVertexBuffer[2]=x;
	mVertexBuffer[3]=y+bmSizeY;
	mVertexBuffer[4]=x+bmSizeX;
	mVertexBuffer[5]=y;
	mVertexBuffer[6]=x+bmSizeX;
	mVertexBuffer[7]=y+bmSizeY;
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
}

- (void) drawClusterTextOpenGL:(NSString *)clusterText pin:(deCartaPin *)pin atX:(float)x y:(float)y{
    if(clusterText==nil || [clusterText length]==0 || pin.ownerOverlay==nil) return;
    
    deCartaOverlay * overlay=pin.ownerOverlay;
    unsigned int textureRef=0;
    deCartaXYInteger * offset=pin.icon.offset;
    deCartaXYInteger * clusterOff=overlay.clusterTextOffset;
    
    float borderSize=OVERLAY_CLUSTER_BORDER_SIZE*g_scale;
    
    UIFont * font=[UIFont fontWithName:OVERLAY_CLUSTER_TEXT_FONT_FAMILY size:OVERLAY_CLUSTER_TEXT_SIZE*g_scale];
    CGSize size=[clusterText sizeWithFont:font];
    
    
	float textOffsetX=OVERLAY_CLUSTER_TEXT_OFFSET_X*g_scale;
    float textOffsetY=OVERLAY_CLUSTER_TEXT_OFFSET_Y*g_scale;
    
    float totalTextHeight=size.height+2*textOffsetY+2*borderSize;
    float totalTextWidth=size.width+2*textOffsetX+2*borderSize;
    
    int sizePower2X=[deCartaUtil getPower2:(int)(totalTextWidth)];
    int sizePower2Y=[deCartaUtil getPower2:(int)(totalTextHeight)];
    
    NSString * key=[NSString stringWithFormat:@"%@|%d|%d|%d",clusterText,overlay.clusterBackgroundColor,overlay.clusterBorderColor,overlay.clusterTextColor];
    if([_clusterTextPool objectForKey:key]!=nil){
        textureRef=[[_clusterTextPool objectForKey:key] unsignedIntValue];
    }else{
        glGenTextures(1, &textureRef);
        glBindTexture(GL_TEXTURE_2D, textureRef);
    
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);// GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);// GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		unsigned char * imgBuf=0;
		@try{
			deCartaImageFormatStruct * formatStruct=(deCartaImageFormatStruct *)&Image_Formats[RGBA];
			imgBuf=malloc(sizePower2X*sizePower2Y*4);
			CGColorSpaceRef	colorSpace = CGColorSpaceCreateDeviceRGB();
			CGContextRef context = CGBitmapContextCreate(imgBuf, sizePower2X, sizePower2Y, 8, sizePower2X * 4, colorSpace, formatStruct->alphaInfo);
			CGContextTranslateCTM(context, 0, sizePower2Y);
			CGContextScaleCTM(context, 1, -1);
			
			CGRect rc;
			rc.origin.x=0;
			rc.origin.y=0;
			rc.size.width=sizePower2X;
			rc.size.height=sizePower2Y;
			CGContextClearRect(context, rc);
			
			float backgroudnColorComps[4];
			backgroudnColorComps[0]=((overlay.clusterBackgroundColor & 0x00ff0000)>>16)/255.0f;
			backgroudnColorComps[1]=((overlay.clusterBackgroundColor & 0x0000ff00)>>8)/255.0f;
			backgroudnColorComps[2]=(overlay.clusterBackgroundColor & 0x000000ff)/255.0f;
			backgroudnColorComps[3]=1;
			CGContextSetRGBFillColor(context, backgroudnColorComps[0], backgroudnColorComps[1], backgroudnColorComps[2], backgroudnColorComps[3]);
			//CGContextSetFillColor(context, backgroudnColorComps);
			float borderColorComps[4];
			borderColorComps[0]=((overlay.clusterBorderColor & 0x00ff0000)>>16)/255.0f;
			borderColorComps[1]=((overlay.clusterBorderColor & 0x0000ff00)>>8)/255.0f;
			borderColorComps[2]=(overlay.clusterBorderColor & 0x000000ff)/255.0f;
			borderColorComps[3]=1;
			CGContextSetRGBStrokeColor(context, borderColorComps[0], borderColorComps[1], borderColorComps[2], borderColorComps[3]);
			//CGContextSetStrokeColor(context, borderColorComps);
			CGContextSetLineWidth(context, borderSize);
			
			//draw whole path
			CGContextMoveToPoint(context, borderSize/2, borderSize/2);
			CGContextAddLineToPoint(context, borderSize*1.5f+size.width+2*textOffsetX, borderSize/2);
			CGContextAddLineToPoint(context, borderSize*1.5f+size.width+2*textOffsetX, borderSize*1.5f+size.height+2*textOffsetY);
			CGContextAddLineToPoint(context, borderSize/2, borderSize*1.5f+size.height+2*textOffsetY);
			CGContextClosePath(context);
			CGContextDrawPath(context, kCGPathFillStroke );
            
			//draw text
			CGContextSelectFont(context, [OVERLAY_CLUSTER_TEXT_FONT_FAMILY UTF8String], OVERLAY_CLUSTER_TEXT_SIZE*g_scale, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(context, kCGTextFill);
			CGContextSetTextMatrix(context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
			
			float textColorComps[4];
			textColorComps[0]=((overlay.clusterTextColor & 0x00ff0000)>>16)/255.0f;
			textColorComps[1]=((overlay.clusterTextColor & 0x0000ff00)>>8)/255.0f;
			textColorComps[2]=(overlay.clusterTextColor & 0x000000ff)/255.0f;
			textColorComps[3]=1;
			CGContextSetRGBFillColor(context, textColorComps[0], textColorComps[1], textColorComps[2], textColorComps[3]);
			//CGContextSetFillColor(context, textColorComps);
			
			float height=size.height*0.8+textOffsetY;
            CGContextShowTextAtPoint(context, borderSize+textOffsetX, borderSize+height, [clusterText UTF8String], strlen([clusterText UTF8String])); 
            
			CGContextRelease(context);
			CGColorSpaceRelease(colorSpace);
			
			glTexImage2D(GL_TEXTURE_2D, 0, formatStruct->texFormat, sizePower2X, sizePower2Y, 0, formatStruct->texFormat, formatStruct->texType, imgBuf);
            [_clusterTextPool setObject:[NSNumber numberWithUnsignedInt:textureRef] forKey:key];
			
			free(imgBuf);
		}
		@catch (NSException * e) {
			[deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame drawClusterTextOpenGL texture exception:%d",textureRef]];
			glDeleteTextures(1, &textureRef);
			textureRef=0;
            
            if(imgBuf) free(imgBuf);
			
		}
		
	}
    if(textureRef==0) return;
	
	glBindTexture(GL_TEXTURE_2D, textureRef);
	
	x-=offset.x;
    y-=offset.y;
    x+=clusterOff.x;
    y+=clusterOff.y;
	deCartaOffsetReference relativeTo=overlay.clusterTextOffsetRelativeTo;
    if(relativeTo==OVERLAY_CLUSTER_TEXT_BOTTOM_RIGHT){
        x-=totalTextWidth;
        y-=totalTextHeight;
    }else if(relativeTo==OVERLAY_CLUSTER_TEXT_BOTTOM_LEFT){
        y-=totalTextHeight;
    }else if(relativeTo==OVERLAY_CLUSTER_TEXT_TOP_RIGHT){
        x-=totalTextWidth;
    }
    
	mVertexBuffer[0]=x;
	mVertexBuffer[1]=y;
	mVertexBuffer[2]=x;
	mVertexBuffer[3]=y+sizePower2Y;
	mVertexBuffer[4]=x+sizePower2X;
	mVertexBuffer[5]=y;
	mVertexBuffer[6]=x+sizePower2X;
	mVertexBuffer[7]=y+sizePower2Y;
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
}



-(void)zoomViewTo:(float)newZoomLevel atCenter:(deCartaXYFloat *)zoomCenterXY{
	if(_zooming || newZoomLevel==_zoomLevel) return;
	if(newZoomLevel < g_config.ZOOM_LOWER_BOUND || newZoomLevel > g_config.ZOOM_UPPER_BOUND){
		//Log.e("TilesView","zoomTo invalid zoom level:"+newZoomLevel+", must between "+g_config.ZOOM_LOWER_BOUND+"-"+g_config.ZOOM_UPPER_BOUND);
		return;
	}
	@try{
		//[deCartaLogger debug:[NSString stringWithFormat:@"MapView zoomViewTo:%f begin:",newZoomLevel]];
		_zooming=TRUE;
		if(zoomCenterXY.x!=_displaySize.x/2 || zoomCenterXY.y!=_displaySize.y/2){
			//[deCartaLogger debug:[NSString stringWithFormat:@"MapView zoomViewTo zoomCenter:%@ displaySize:%@",zoomCenterXY,_displaySize]];
			double deltaX=(zoomCenterXY.x-_displaySize.x/2)*(pow(2,newZoomLevel-_zoomLevel)-1);
			float moveX=-(float)(deltaX*pow(2, _centerXYZ.z-newZoomLevel));
			double deltaY=(zoomCenterXY.y-_displaySize.y/2)*(pow(2,newZoomLevel-_zoomLevel)-1);
			float moveY=-(float)(deltaY*pow(2, _centerXYZ.z-newZoomLevel));
			
			_centerXY.x-=moveX;
			_centerXY.x=[deCartaUtil mercXMod:_centerXY.x atZoom:_centerXYZ.z];
            
            if(moveY>0){
                if(_centerXY.y>=MERC_X_MODS[_centerXYZ.z]) moveY=0;
                else if(_centerXY.y+moveY>MERC_X_MODS[_centerXYZ.z])
                    moveY=MERC_X_MODS[_centerXYZ.z]-_centerXY.y;
            }else if(moveY<0){
                if(_centerXY.y<=-MERC_X_MODS[_centerXYZ.z]) moveY=0;
                else if (_centerXY.y+moveY<-MERC_X_MODS[_centerXYZ.z])
                    moveY=-MERC_X_MODS[_centerXYZ.z]-_centerXY.y;
            }
            
			_centerXY.y+=moveY;
			_centerDelta.x+=moveX;
			_centerDelta.y+=moveY;
		}
		
		_zoomLevel=newZoomLevel;
		
		if(_zoomLevel>_centerXYZ.z+0.5+ZOOMING_LAG || _zoomLevel<_centerXYZ.z-0.5-ZOOMING_LAG){
			int roundLevel=round(_zoomLevel);
			if(roundLevel> g_config.ZOOM_UPPER_BOUND || roundLevel<g_config.ZOOM_LOWER_BOUND) return;
			
			//clearTilesWaitForLoading();
			for(int i=0;i<[_mapLayers count];i++){
				deCartaMapLayer * mapLayer=[_mapLayers objectAtIndex:i];
				if(!mapLayer.visible)continue; 
				//[deCartaLogger debug:[NSString stringWithFormat:@"MapView zoomViewTo mapLayer percent:%f,level:%d,zoomLayer percent:%f,level:%d",
				//mapLayer.mainLayerDrawPercent,_centerXYZ.z,mapLayer.zoomLayerDrawPercent,mapLayer.centerXYZ.z]];
				float factorMain=1.0f;
                float factorZoom=1.0f;
                if(roundLevel>mapLayer.centerXYZ.z){
                    factorZoom=powf(ZOOM_PENALTY, roundLevel-mapLayer.centerXYZ.z);
                    if(roundLevel>_centerXYZ.z){
                        factorMain=powf(ZOOM_PENALTY, roundLevel-_centerXYZ.z);
                    }
                }
                if(mapLayer.mainLayerDrawPercent>=CLONE_MAP_LAYER_DRAW_PERCENT || mapLayer.centerXY==nil || mapLayer.mainLayerDrawPercent*factorMain>=mapLayer.zoomLayerDrawPercent*factorZoom){
					mapLayer.centerXY=[[[deCartaXYDouble alloc] initWithXd:_centerXY.x andYd:_centerXY.y] autorelease];
					mapLayer.centerXYZ=[[[deCartaXYZ alloc] initWithX:_centerXYZ.x andY:_centerXYZ.y andZ:_centerXYZ.z] autorelease];
					mapLayer.centerDelta=[[[deCartaXYFloat alloc] initWithXf:_centerDelta.x andYf:_centerDelta.y] autorelease];
					mapLayer.zoomLayerDrawPercent=mapLayer.mainLayerDrawPercent;
					mapLayer.mainLayerDrawPercent=0;
				}
			}
			
			double mapScale=pow(2, roundLevel-_centerXYZ.z);
			
			deCartaTileGridResponse * resp= [deCartaUtil handlePortrayMapRequest:[[[deCartaXYDouble alloc] initWithXd:_centerXY.x*mapScale andYd:_centerXY.y*mapScale] autorelease] atZ:roundLevel];
			[self renderMap:resp];
			_fadingStartTime=[NSDate timeIntervalSinceReferenceDate];
			
		}
		_zooming=FALSE;
	}
	@catch(NSException * e){
		[deCartaLogger warn:[NSString stringWithFormat:@"MapView zoomViewTo exception name:%@,reason:%@",[e name],[e reason] ]];
		//throw APIException.wrapToAPIException(e);
	}
	@finally {
		_zooming=FALSE;
	}
	
}

-(void)moveViewX:(float)left andY:(float)top {
	if (_zooming)
		return;
	
	if (_centerXY==nil) {
		return;
	}
	
	if(left==0 && top==0) return;
	
	double mapScale=pow(2, _centerXYZ.z-_zoomLevel);
	float moveX=left*(float)mapScale;
	float moveY=top*(float)(mapScale);
	
	_centerXY.x-=moveX;
	_centerXY.x=[deCartaUtil mercXMod:_centerXY.x atZoom:_centerXYZ.z];
	
	if(moveY>0){
        if(_centerXY.y>=MERC_X_MODS[_centerXYZ.z]) moveY=0;
        else if(_centerXY.y+moveY>MERC_X_MODS[_centerXYZ.z])
            moveY=MERC_X_MODS[_centerXYZ.z]-_centerXY.y;
    }else if(moveY<0){
        if(_centerXY.y<=-MERC_X_MODS[_centerXYZ.z]) moveY=0;
        else if (_centerXY.y+moveY<-MERC_X_MODS[_centerXYZ.z])
            moveY=-MERC_X_MODS[_centerXYZ.z]-_centerXY.y;
    }
    		
	_centerXY.y+=moveY;
	_centerDelta.x+=moveX;
	_centerDelta.y+=moveY;
	
	int tileSize=g_config.TILE_SIZE;
	if(ABS(_centerDelta.x)>tileSize || ABS(_centerDelta.y)>tileSize){
		int numX=round(_centerDelta.x/tileSize);
		int numY=round(_centerDelta.y/tileSize);
		_centerXYZ.x-=numX;
		_centerXYZ.x=[deCartaUtil indexXMod:_centerXYZ.x atZoom:_centerXYZ.z];
		_centerXYZ.y+=numY;
		_centerDelta.x-=(numX*tileSize);
		_centerDelta.y-=(numY*tileSize);
		
		_panDirection.x=numX>=0?1:-1;
		_panDirection.y=numY>=0?1:-1;
		
		//refreshTileRequests(numX>=0?1:-1, numY>=0?1:-1);
	}
	
	
}



- (void)drawFrame
{
	//[deCartaLogger debug:@"MapView drawFrame start"];
	
	if(_centerXY==nil){
		[self setFramebuffer];
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        float bgr=((g_config.BACKGROUND_COLOR&0x00ff0000)>>16)/255.0f;
        float bgg=((g_config.BACKGROUND_COLOR&0x0000ff00)>>8)/255.0f;
        float bgb=(g_config.BACKGROUND_COLOR&0x000000ff)/255.0f;
        glClearColor(bgr,bgg,bgb,1);
        [self pauseView];
        [self presentFramebuffer];
        
        return;
	}
	
	BOOL movingL=FALSE;
	BOOL movingJustDoneL=FALSE;
    deCartaEventListener *movingListener=[[_easingRecord.listener retain] autorelease];
	BOOL zoomingL=FALSE;
	BOOL zoomingJustDoneL=FALSE;
    deCartaEventListener *zoomingListener=[[_zoomingRecord.listener retain] autorelease];
	BOOL rotatingX=FALSE;
	BOOL rotatingXJustDoneL=FALSE;
	BOOL rotatingZ=FALSE;
	BOOL rotatingZJustDoneL=FALSE;
	
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[self setFramebuffer];
	
	@synchronized(_drawingLock){
		if(_mapMode.xRotating){
			double currentTime=[[NSDate date] timeIntervalSinceReferenceDate];
			float newRotationX;
			
			if(currentTime<_mapMode.xRotationEndTime){
				float rotateDirection=_mapMode.xRotationEnd>_mapMode.xRotation?ABS(MAP_TILT_MIN):-ABS(MAP_TILT_MIN);
				newRotationX=_mapMode.xRotationEnd-(float)(_mapMode.xRotationEndTime-currentTime)/XROTATION_TIME*rotateDirection;
				rotatingX=TRUE;
			}else{
				newRotationX=_mapMode.xRotationEnd;
				rotatingXJustDoneL=TRUE;
			}
			//Log.i("TilesView","onDraw rotatingX currentTime,endTime,newRotatinX,oldRotationX:"+currentTime/1000000+","+mapModeRecord.xRotationEndTime/1000000+","+newRotationX+","+mapModeRecord.xRotation);
			
			_lastXRotation=_mapMode.xRotation;
			[_mapMode setXRotation:newRotationX withDisplaySize:_displaySize];
			
			if(currentTime>=_mapMode.xRotationEndTime){
				[_mapMode resetXEasing];
			}
		}
		
		if(_mapMode.zRotating){
			double currentTime=[[NSDate date] timeIntervalSinceReferenceDate];
			float newRotationZ;
			
			if(currentTime<_mapMode.zRotationEndTime){
				float diff=_mapMode.zRotationEnd-_mapMode.zRotation;
				if(diff>180) diff-=360;
				else if(diff<-180) diff+=360;
				float rotateDirection=(diff>0?180:-180);
				newRotationZ=_mapMode.zRotationEnd-(float)(_mapMode.zRotationEndTime-currentTime)/ZROTATION_TIME*rotateDirection;
				rotatingZ=TRUE;
			}else{
				newRotationZ=_mapMode.zRotationEnd;
				rotatingZJustDoneL=TRUE;
			}
			//Log.i("TilesView","onDraw rotatingZ currentTime,endTime,newRotatinZ,oldRotationZ:"+currentTime/1000000+","+mapModeRecord.zRotationEndTime/1000000+","+newRotationZ+","+mapModeRecord.zRotation);
			_lastZRotation=_mapMode.zRotation;
			[_mapMode setZRotation:newRotationZ withDisplaySize:_displaySize];
			
			if(currentTime>=_mapMode.zRotationEndTime){
				[_mapMode resetZEasing];
			}
		}
		
		if(_zoomingRecord.digitalZooming){
			double currentTime=[[NSDate date] timeIntervalSinceReferenceDate];
			float newZoomLevel;
			
			double timeLeft=_zoomingRecord.digitalZoomEndTime-currentTime;
            //if(currentTime<_zoomingRecord.digitalZoomEndTime){
            if(timeLeft>0){
				//int zoomDirection=_zoomingRecord.zoomToLevel>_zoomLevel?1:-1;
				//newZoomLevel=_zoomingRecord.zoomToLevel-(float)(_zoomingRecord.digitalZoomEndTime-currentTime)/DIGITAL_ZOOMING_TIME_PER_LEVEL*zoomDirection;
                newZoomLevel=_zoomingRecord.zoomToLevel-(float)(_zoomingRecord.speed*timeLeft);
				zoomingL=TRUE;
			}else{
				newZoomLevel=_zoomingRecord.zoomToLevel;
				zoomingJustDoneL=TRUE;
			}
			@try{
				[self zoomViewTo:newZoomLevel atCenter:_zoomingRecord.zoomCenterXY];
			}@catch(NSException * e){
				[deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame zoomView e.name:%@,e.reason:%@",[e name],[e reason]]];
			}
			if(currentTime>=_zoomingRecord.digitalZoomEndTime){
				resetZoomingRecord(&_zoomingRecord);
			}
            //[deCartaLogger debug:[NSString stringWithFormat:@"MapView drawFrame digital zooming newLevel:%f",newZoomLevel]];
			
        }
		else if(g_config.DECELERATE>0 && _easingRecord.speed>0){
			double currentTime=[[NSDate date] timeIntervalSinceReferenceDate];
			double timeElapsed=currentTime-_easingRecord.startMoveTime;
			double newSpeed=_easingRecord.speed*pow(_easingRecord.decelerateRate, timeElapsed/_easingRecord.TIME_SCALE)   ;
			double distance=0;
			//if(newSpeed<=_easingRecord.speed*_easingRecord.MINIMUM_SPEED_RATIO){
			if(newSpeed<=_easingRecord.CUTOFF_SPEED){
				distance=-_easingRecord.TIME_SCALE*(_easingRecord.speed-newSpeed)/log(_easingRecord.decelerateRate)-_easingRecord.movedDistance;
				newSpeed=0;
				movingJustDoneL=TRUE;
			}else{
				distance=-_easingRecord.TIME_SCALE*(_easingRecord.speed-newSpeed)/log(_easingRecord.decelerateRate)-_easingRecord.movedDistance;
				_easingRecord.movedDistance+=(float)distance;
				
				movingL=TRUE;
			}
			[self moveViewX:(float)(distance)*_easingRecord.direction.x andY:(float)(distance)*_easingRecord.direction.y];
			if(newSpeed<=0){
				[self resetEasingRecord:(&_easingRecord)];
			}
			//[deCartaLogger debug:[NSString stringWithFormat:@"MapView drawFrame ease distance:%f,timeElapsed:%f,newSpeed:%f",distance,timeElapsed,newSpeed]];
		}
        
		//@try{
		/*glDisable(GL_DITHER);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
		glHint(GL_POINT_SMOOTH, GL_NICEST);
		glHint(GL_LINE_SMOOTH, GL_NICEST);*/
		
		//config matrix
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glFrustumf(-_displaySize.x/2, _displaySize.x/2, -_displaySize.y/2, _displaySize.y/2, _mapMode.nearZ, _mapMode.farZ+1);
		
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glTranslatef(-_displaySize.x/2.0f, _displaySize.y/2, -_mapMode.middleZ);
		glRotatef(180,1,0,0);
		
		glTranslatef(_displaySize.x/2.0f, _displaySize.y/2.0f, 0);
		glScalef(_mapMode.scale, _mapMode.scale, _mapMode.scale);
		glRotatef(_mapMode.xRotation, 1, 0, 0);
		glRotatef(_mapMode.zRotation, 0, 0, 1);
		glTranslatef(-_displaySize.x/2.0f, -_displaySize.y/2.0f, 0);
		//end of config matrix
		
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        float bgr=((g_config.BACKGROUND_COLOR&0x00ff0000)>>16)/255.0f;
        float bgg=((g_config.BACKGROUND_COLOR&0x0000ff00)>>8)/255.0f;
        float bgb=(g_config.BACKGROUND_COLOR&0x000000ff)/255.0f;
        glClearColor(bgr,bgg,bgb,1);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, mVertexBuffer);
		glTexCoordPointer(2, GL_BYTE, 0, TEXTURE_COORDS);
		glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
		glColor4f(1, 1, 1, 1);
		glLineWidth(1);
		glPointSize(1);
		glDisable(GL_BLEND);
		glDepthMask(FALSE);
        
        float scaleToM=_mapMode.middleZ/(_mapMode.nearZ*_mapMode.scale);
		
		//draw empty tiles
		float displaySizeXR=_mapMode.displaySizeConvXR;
		float displaySizeXL=_mapMode.displaySizeConvXL;
		float displaySizeYB=_mapMode.displaySizeConvYB;
		float displaySizeYT=_mapMode.displaySizeConvYT;
		
		int gridSizeXR=_mapMode.gridSizeConvXR;
		int gridSizeXL=_mapMode.gridSizeConvXL;
		int gridSizeYB=_mapMode.gridSizeConvYB;
		int gridSizeYT=_mapMode.gridSizeConvYT;
		
		float centerScreenX=_displaySize.x/2.0f+_centerDelta.x;
		float centerScreenY=_displaySize.y/2.0f+_centerDelta.y;
		
		int tileSize=g_config.TILE_SIZE;
		int border=g_config.BORDER;
		
		if(_centerXY){
			
			glDisable(GL_TEXTURE_2D);
			float red=((g_config.BACKGROUND_GRID_COLOR&0x00ff0000)>>16)/255.0f;
            float green=((g_config.BACKGROUND_GRID_COLOR&0x0000ff00)>>8)/255.0f;
            float blue=(g_config.BACKGROUND_GRID_COLOR&0x000000ff)/255.0f;
			glColor4f(red, green, blue, 1);
			
			float tx=(((int)_centerDelta.x%tileSize)-tileSize)%tileSize;
			float ty=(((int)_centerDelta.y%tileSize)-tileSize)%tileSize;
			float displaySizeX=MAX(displaySizeXR,displaySizeXL)*2;
			float displaySizeY=MAX(displaySizeYB,displaySizeYT)*2;
			int sizeX=(int)ceil((-tx+displaySizeX)/tileSize);
			int sizeY=(int)ceil((-ty+displaySizeY)/tileSize);
			float oriX=(_displaySize.x-displaySizeX)/2;
			float oriY=(_displaySize.y-displaySizeY)/2;
			for(int i=1;i<sizeY;i++){
				mVertexBuffer[0]=oriX;
				mVertexBuffer[1]=oriY+tileSize*i+ty;
				mVertexBuffer[2]=oriX+displaySizeX;
				mVertexBuffer[3]=oriY+tileSize*i+ty;
				glDrawArrays(GL_LINE_STRIP, 0, 2);
				
			}
			for(int i=1;i<sizeX;i++){
				mVertexBuffer[0]=oriX+tileSize*i+tx;
				mVertexBuffer[1]=oriY;
				mVertexBuffer[2]=oriX+tileSize*i+tx;
				mVertexBuffer[3]=oriY+displaySizeY;
				glDrawArrays(GL_LINE_STRIP, 0, 2);
				
			}	
			glEnable(GL_TEXTURE_2D);
			glColor4f(1, 1, 1, 1);
		}
		
		//draw tiles
		NSMutableArray * requestTiles = [[NSMutableArray alloc] init];
		[_drawingTiles removeAllObjects];
		BOOL haveDrawingTiles = FALSE;
		BOOL fading = FALSE;
		double scaleF = pow(2, _zoomLevel - _centerXYZ.z);
		double topLeftXf = _centerXY.x * scaleF - _displaySize.x / 2;
		double topLeftYf = _centerXY.y * scaleF + _displaySize.y / 2;
		deCartaXYInteger * tileSizeXY=[[[deCartaXYInteger alloc] initWithXi:tileSize andYi:tileSize] autorelease];
		
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		for (int s = 0; s < [_mapLayers count]; s++) {
			deCartaMapLayer * mapLayer = [_mapLayers objectAtIndex:s];
			if(!mapLayer.visible) continue;
			
			NSMutableSet *willDrawXYZs=[NSMutableSet set];
            NSMutableArray *willDrawTiles=[NSMutableArray array];
            NSMutableArray *willDrawXYs=[NSMutableArray array];
            double zoomScale=pow(2,_zoomLevel-_centerXYZ.z);
            int leftDistO,rightDistO,topDistO,bottomDistO;
            int leftDist=leftDistO=(int)(floor((-_centerDelta.x*zoomScale-displaySizeXL)/(g_config.TILE_SIZE*zoomScale)+0.5));
            //if(leftDist<-(gridSize.x)/2) leftDist=-(gridSize.x)/2;
            int rightDist=rightDistO=(int)(ceil((-_centerDelta.x*zoomScale+displaySizeXR)/(g_config.TILE_SIZE*zoomScale)-0.5));
            //if(rightDist>(gridSize.x)/2) rightDist=(gridSize.x)/2;
            int topDist=topDistO=(int)(floor((-_centerDelta.y*zoomScale-displaySizeYT)/(g_config.TILE_SIZE*zoomScale)+0.5));
            //if(topDist<-(gridSize.y)/2) topDist=-(gridSize.y)/2;
            int bottomDist=bottomDistO=(int)(ceil((-_centerDelta.y*zoomScale+displaySizeYB)/(g_config.TILE_SIZE*zoomScale)-0.5));
            //if(bottomDist>(gridSize.y)/2) bottomDist=(gridSize.y)/2;
            if(bottomDist>=topDist && rightDist>=leftDist){
                for (int i = topDist; i <= bottomDist; i++) {
                    int yi = _centerXYZ.y - i;
                    for (int j = leftDist; j <= rightDist; j++) {
                        int xi = _centerXYZ.x + j;
                        deCartaTile *requestTile = [mapLayer createTile];
                        requestTile.xyz.x = xi;
                        requestTile.xyz.y = yi;
                        requestTile.xyz.z = _centerXYZ.z;
                        requestTile.xyz.x=[deCartaUtil indexXMod:requestTile.xyz.x atZoom:requestTile.xyz.z];
                        if(!haveDrawingTiles) [_drawingTiles addObject:requestTile];
                        
                        //long availTime=0;
                        unsigned int textureRef=0;
                        if([_tileTextureRefs objectForKey:requestTile]){
                            textureRef=[(NSNumber *)[_tileTextureRefs objectForKey:requestTile] unsignedIntValue];
                        }else{
                            UIImage *tileResponse = [_tileImages removeObjectForKey:requestTile andExecDelFunc:FALSE];
                            if (tileResponse != nil) {
                                glGenTextures(1, &textureRef);
                                glBindTexture(GL_TEXTURE_2D, textureRef);
                                @try{
                                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                                    BOOL success=[deCartaImageUtil image2Texture:tileResponse texRef:textureRef format:mapLayer.mapLayerProperty.format size:tileSizeXY sizePower2:tileSizeXY];
                                    if(!success){
                                        [deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame texture failed:%d",textureRef]];
                                        glDeleteTextures(1, &textureRef);
                                        textureRef=0;
                                        continue;
                                    }else {
                                        [_tileTextureRefs setObject:[NSNumber numberWithUnsignedInt:textureRef] forKey:requestTile];
                                        //[deCartaLogger debug:[NSString stringWithFormat:@"MapView drawFrame mapLayer put texture:%d",textureRef]];
                                    }
                                }@catch(NSException * e){
                                    [deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame texture exception:%d",textureRef]];
                                    glDeleteTextures(1, &textureRef);
                                    textureRef=0;
                                }
                                //availTime=tileResponse.availTime;
                            }else {
                                requestTile.distanceFromCenter = ABS(i) + ABS(j);
                                if(i*_panDirection.y<=0 && j*_panDirection.x<=0){
                                    [requestTiles insertObject:requestTile atIndex:0];
                                }else{
                                    [requestTiles addObject:requestTile];
                                }
                            }
                        }
                        if(textureRef==0) continue;
                        else{
                            [willDrawXYZs addObject:requestTile.xyz];
                            [willDrawTiles addObject:requestTile];
                            [willDrawXYs addObject:[deCartaXYInteger XYWithX:j andY:i]];
                        }
                        
                        
                    }
                }
                mapLayer.mainLayerDrawPercent=(float)[willDrawTiles count]/((bottomDistO-topDistO+1)*(rightDistO-leftDistO+1));
                
            }else{
                mapLayer.mainLayerDrawPercent=0;
            }
            haveDrawingTiles=true;
            
            if (mapLayer.centerXY != nil && (mapLayer.mainLayerDrawPercent<1.0f || [NSDate timeIntervalSinceReferenceDate]-_fadingStartTime<g_config.FADING_TIME)) {
                int blX=_centerXYZ.x+leftDist;
                int trX=_centerXYZ.x+rightDist;
                int blY=_centerXYZ.y-bottomDist;
                int trY=_centerXYZ.y-topDist;
                
                double xxZL = 0, yyZL = 0;
                double mapScaleZL = pow(2, mapLayer.centerXYZ.z - _centerXYZ.z);
                xxZL = mapLayer.centerXY.x - _centerXY.x*mapScaleZL;
                yyZL = -(mapLayer.centerXY.y - _centerXY.y*mapScaleZL);
                
                float mapLayerCenterScreenX=_displaySize.x/2.0f+mapLayer.centerDelta.x;
                float mapLayerCenterScreenY=_displaySize.y/2.0f+mapLayer.centerDelta.y;
                
                double zoomScaleZL=pow(2,_zoomLevel-mapLayer.centerXYZ.z);
                int leftDistOZL,rightDistOZL,topDistOZL,bottomDistOZL;
                int leftDistZL=leftDistOZL=(int)(floor((-(xxZL+mapLayer.centerDelta.x)*zoomScaleZL-displaySizeXL)/(g_config.TILE_SIZE*zoomScaleZL)+0.5));
                if(leftDistZL<-gridSizeXL) leftDistZL=-gridSizeXL;
                int rightDistZL=rightDistOZL=(int)(ceil((-(xxZL+mapLayer.centerDelta.x)*zoomScaleZL+displaySizeXR)/(g_config.TILE_SIZE*zoomScaleZL)-0.5));
                if(rightDistZL>gridSizeXR) rightDistZL=gridSizeXR;
                int topDistZL=topDistOZL=(int)(floor((-(yyZL+mapLayer.centerDelta.y)*zoomScaleZL-displaySizeYT)/(g_config.TILE_SIZE*zoomScaleZL)+0.5));
                if(topDistZL<-gridSizeYT) topDistZL=-gridSizeYT;
                int bottomDistZL=bottomDistOZL=(int)(ceil((-(yyZL+mapLayer.centerDelta.y)*zoomScaleZL+displaySizeYB)/(g_config.TILE_SIZE*zoomScaleZL)-0.5));
                if(bottomDistZL>gridSizeYB) bottomDistZL=gridSizeYB;
                if(bottomDistZL>=topDistZL && rightDistZL>=leftDistZL){
                    glPushMatrix();
                    glTranslatef(_displaySize.x/2.0f,_displaySize.y/2.0f,0);
                    glScalef((float)zoomScaleZL, (float)zoomScaleZL, 1);
                    glTranslatef(-_displaySize.x/2.0f+(float)xxZL,-_displaySize.y/2.0f+(float)yyZL,0);
                    int drawNum = 0;
                    for (int i = topDistZL; i <= bottomDistZL; i++) {
                        int yi = mapLayer.centerXYZ.y - i;
                        for (int j = leftDistZL; j <= rightDistZL; j++) {
                            int xi = mapLayer.centerXYZ.x + j;
                            deCartaTile *requestTile = [mapLayer createTile];
                            requestTile.xyz.x = xi;
                            requestTile.xyz.y = yi;
                            requestTile.xyz.z = mapLayer.centerXYZ.z;
                            requestTile.xyz.x=[deCartaUtil indexXMod:requestTile.xyz.x atZoom:requestTile.xyz.z];
                            unsigned int textureRef=0;
                            if([_tileTextureRefs objectForKey:requestTile]){
                                textureRef=[(NSNumber *)[_tileTextureRefs objectForKey:requestTile] unsignedIntValue];
                                
                            }else{
                                UIImage *tileResponse = [_tileImages removeObjectForKey:requestTile andExecDelFunc:FALSE];
                                if (tileResponse != nil) {
                                    glGenTextures(1, &textureRef);
                                    glBindTexture(GL_TEXTURE_2D, textureRef);
                                    @try{
                                        //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                                        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                                        //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                                        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                                        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                                        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                                        BOOL success=[deCartaImageUtil image2Texture:tileResponse texRef:textureRef format:mapLayer.mapLayerProperty.format size:tileSizeXY sizePower2:tileSizeXY];
                                        if(!success){
                                            [deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame zoomLayer texture failed:%d",textureRef]];
                                            glDeleteTextures(1, &textureRef);
                                            textureRef=0;
                                            continue;
                                        }else {
                                            [_tileTextureRefs setObject:[NSNumber numberWithUnsignedInt:textureRef] forKey:requestTile];
                                            //[deCartaLogger debug:[NSString stringWithFormat:@"MapView drawFrame zoomLayer put texture:%d",textureRef]];
                                        }
                                    }@catch(NSException * e){
                                        [deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame zoomLayer texture exception:%d",textureRef]];
                                        glDeleteTextures(1, &textureRef);
                                        textureRef=0;
                                    }
                                    //availTime=tileResponse.availTime;
                                }
                                
                            }
                            if(textureRef==0) continue;
                            if([NSDate timeIntervalSinceReferenceDate]-_fadingStartTime<g_config.FADING_TIME
                               || ![deCartaUtil covered:[deCartaXYZ XYZWithX:xi andY:yi andZ:mapLayer.centerXYZ.z] byTiles:willDrawXYZs z:_centerXYZ.z blX:blX blY:blY trX:trX trY:trY]){
                            
                                glBindTexture(GL_TEXTURE_2D, textureRef);
                                float sx=mapLayerCenterScreenX+(j)*tileSize;
                                float sy=mapLayerCenterScreenY+(i)*tileSize;
                                mVertexBuffer[0]=sx-tileSize/2.0f+border/2.0f;
                                mVertexBuffer[1]=sy-tileSize/2.0f+border/2.0f;
                                mVertexBuffer[2]=sx-tileSize/2.0f+border/2.0f;
                                mVertexBuffer[3]=sy+tileSize/2.0f-border/2.0f;
                                mVertexBuffer[4]=sx+tileSize/2.0f-border/2.0f;
                                mVertexBuffer[5]=sy-tileSize/2.0f+border/2.0f;
                                mVertexBuffer[6]=sx+tileSize/2.0f-border/2.0f;
                                mVertexBuffer[7]=sy+tileSize/2.0f-border/2.0f;
                                
                                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                            }
                            drawNum++;
                            
                        }
                    }
                    mapLayer.zoomLayerDrawPercent=(float)drawNum/((bottomDistOZL-topDistOZL+1)*(rightDistOZL-leftDistOZL+1));
                    glPopMatrix();
                }else{
                    mapLayer.zoomLayerDrawPercent=0;
                }
                
            }else mapLayer.zoomLayerDrawPercent=0;  
            
            //draw the normal tiles
            glPushMatrix();
            glTranslatef(_displaySize.x/2.0f,_displaySize.y/2.0f,0);
            glScalef((float)zoomScale, (float)zoomScale, 1);
            glTranslatef(-_displaySize.x/2.0f,-_displaySize.y/2.0f,0);
            
            for(int ii=0;ii<[willDrawTiles count];ii++){
                deCartaTile *requestTile=[willDrawTiles objectAtIndex:ii];
                unsigned int textureRef=[(NSNumber *)[_tileTextureRefs objectForKey:requestTile] unsignedIntValue];
                if(textureRef==0){
                    [deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame texture 0:%@",[requestTile description]]];
                    continue;
                }
                glBindTexture(GL_TEXTURE_2D, textureRef);
                float sx=centerScreenX+([(deCartaXYInteger *)[willDrawXYs objectAtIndex:ii] x])*tileSize;
                float sy=centerScreenY+([(deCartaXYInteger *)[willDrawXYs objectAtIndex:ii] y])*tileSize;
                mVertexBuffer[0]=sx-tileSize/2.0f+border/2.0f;
                mVertexBuffer[1]=sy-tileSize/2.0f+border/2.0f;
                mVertexBuffer[2]=sx-tileSize/2.0f+border/2.0f;
                mVertexBuffer[3]=sy+tileSize/2.0f-border/2.0f;
                mVertexBuffer[4]=sx+tileSize/2.0f-border/2.0f;
                mVertexBuffer[5]=sy-tileSize/2.0f+border/2.0f;
                mVertexBuffer[6]=sx+tileSize/2.0f-border/2.0f;
                mVertexBuffer[7]=sy+tileSize/2.0f-border/2.0f;
                
                double fadingTime=g_config.FADING_TIME;
                if (fadingTime > 0){
                    double fadeTime = _fadingStartTime;
                    double curTime=[NSDate timeIntervalSinceReferenceDate];
                    float fadingAnim = (float)((curTime - fadeTime)/fadingTime);
                    if (fadingAnim > 1)	fadingAnim = 1;
                    if(fadingAnim<1){
                        fading=TRUE;
                        
                    }
                    
                    glColor4f(1, 1, 1, (FADING_START_ALPHA+fadingAnim*(255-FADING_START_ALPHA))/255.0f);
                    
                }				
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
            }
            
            glPopMatrix();
            glColor4f(1,1,1,1);
            
        }
        glDisable(GL_BLEND);
		//end of draw tiles
		
		//draw the shapes
		glEnable(GL_BLEND);
		glDisable(GL_TEXTURE_2D);
		for (int i = 0; i < [_shapes count]; i++) {
			deCartaShape * shape = [_shapes objectAtIndex:i];
			if(!shape.visible){
				continue;
			}
			deCartaXYDouble * tl=[[[deCartaXYDouble alloc] initWithXd:topLeftXf andYd:topLeftYf] autorelease];
			
			if ([shape isKindOfClass:[deCartaPolyline class]]){
				deCartaPolyline * polyline=(deCartaPolyline *)shape;
				if(polyline.positions==nil) continue;
				[polyline renderGL:tl zoomLevel:_zoomLevel z:_centerXYZ.z tiles:_drawingTiles];
			}else if([shape isKindOfClass:[deCartaCircle class]]){
				deCartaCircle * circle=(deCartaCircle *)shape;
				if(circle.position==nil){
					continue;
				}
				[circle renderGL:tl atZoom:_zoomLevel];
			}else if([shape isKindOfClass:[deCartaPolygon class]]){
				deCartaPolygon * polygon=(deCartaPolygon *)shape;
				if(polygon.positions==nil) continue;
				[polygon renderGL:tl atZoom:_zoomLevel];
			}
				
		}
		glColor4f(1, 1, 1, 1);
		glDisable(GL_BLEND);
		glEnable(GL_TEXTURE_2D);
		glVertexPointer(2, GL_FLOAT, 0, mVertexBuffer);
		
		//draw the overlays
		double overlayZoomScale=pow(2,_zoomLevel-ZOOM_LEVEL);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		for(int i=0;i<[_overlays count];i++){
			deCartaOverlay * overlay=[_overlays objectAtIndex:i];
			
			NSArray * clusters=[overlay getVisiblePinsAtZ:_centerXYZ.z tiles:_drawingTiles];
			//[deCartaLogger debug:[NSString stringWithFormat:@"MapView drawFrame visible pins count:%d,z:%d",[pins count],_centerXYZ.z]];
			for(int j=[clusters count]-1;j>=0;j--){
				NSArray * cluster=[clusters objectAtIndex:j];
                NSMutableArray * visiblePins=[[[NSMutableArray alloc] init] autorelease];
                for(int ii=0;ii<[cluster count];ii++){
                    deCartaPin * pinL=[cluster objectAtIndex:ii];
                    if(pinL.icon.image!=nil && pinL.mercXY!=nil && pinL.visible){
                        [visiblePins addObject:pinL];
                    }
                }
                if([visiblePins count]==0) continue;
                
                deCartaPin * pin=[visiblePins objectAtIndex:0];
				
                float x=(float)(pin.mercXY.x*overlayZoomScale-topLeftXf);
				float y=(float)(-pin.mercXY.y*overlayZoomScale+topLeftYf);
				
				deCartaRotationTilt * rt=pin.rotationTilt;
				float zRot=rt.rotation;
				if(rt.rotateRelativeTo==ROTATE_RELATIVE_TO_MAP){
					zRot+=_mapMode.zRotation;
				}
				float xRot=rt.tilt;
				if(rt.tiltRelativeTo==TILT_RELATIVE_TO_SCREEN){
					xRot-=_mapMode.xRotation;
				}
				glPushMatrix();
				glTranslatef(x, y,0);
				
				glRotatef(-_mapMode.zRotation,0,0,1);
				glRotatef(xRot, 1,0, 0);
				glRotatef(zRot,0,0,1);
                glScalef(scaleToM, scaleToM, 1);
				[self drawOverlayItemOpenGL:pin atX:0 y:0];
                if(overlay.clustering && [visiblePins count]>1){
                    [self drawClusterTextOpenGL:[NSString stringWithFormat:@"%d",[visiblePins count]] pin:pin atX:0 y:0];
                }
				glPopMatrix();
			}
		}
		glDisable(GL_BLEND);
		
		//draw info window
		if(_infoWindow.visible && _infoWindow.mercXY!=nil) {
			double infoZoomScale=pow(2,_zoomLevel-ZOOM_LEVEL);
			float x=(float)(_infoWindow.mercXY.x*infoZoomScale-topLeftXf);
			float y=(float)(-_infoWindow.mercXY.y*infoZoomScale+topLeftYf);
			
			deCartaRotationTilt * rt=_infoWindow.offsetRotationTilt;
			float zRot=rt.rotation;
			if(rt.rotateRelativeTo==ROTATE_RELATIVE_TO_MAP){
				zRot+=_mapMode.zRotation;
			}
			float xRot=rt.tilt;
			if(rt.tiltRelativeTo==ROTATE_RELATIVE_TO_SCREEN){
				xRot-=_mapMode.xRotation;
			}
			glPushMatrix();
			glTranslatef(x,y,0);
			glRotatef(-_mapMode.zRotation,0,0,1);
			glRotatef(xRot,1,0,0);
			glRotatef(zRot, 0, 0, 1);
			glTranslatef(-_infoWindow.offset.x*scaleToM, -_infoWindow.offset.y*scaleToM, 0);
			
			glRotatef(-zRot,0,0,1);
			glRotatef(-_mapMode.xRotation-xRot,1,0,0);
            glScalef(scaleToM, scaleToM, 1);
			[_infoWindow drawInfoWindow];
			glPopMatrix();
		}
		
		//draw the compass
		if(_compass!=nil && _compass.visible){
			deCartaXYInteger * screenXY=[_compass getScreenXY:_displaySize];
			glDisable(GL_TEXTURE_2D);
			
			glLoadIdentity();
			glTranslatef(-_displaySize.x/2.0f,_displaySize.y/2.0f, -_mapMode.middleZ);
			glRotatef(180,1,0,0);
			
			glTranslatef(_displaySize.x/2.0f,_displaySize.y/2.0f,0);
			float scale=_mapMode.middleZ/_mapMode.nearZ;
			glScalef(scale, scale, scale);
			glTranslatef(screenXY.x-_displaySize.x/2.0f, screenXY.y-_displaySize.y/2.0f, 0);
			glRotatef(_mapMode.xRotation, 1, 0, 0);
			glRotatef(_mapMode.zRotation,0,0,1);
			[_compass renderGL];
		}
		
		
		if([requestTiles count]>0){
			[_tileThreadPool addRequestTiles:requestTiles];
		}
		[requestTiles release];
		
		if(zoomingL || fading || movingL || rotatingX || rotatingZ){
			[self resumeView];
		}else{
			[self pauseView];
		}
		
		
	/*}@catch (NSException * e) {
		[deCartaLogger warn:[NSString stringWithFormat:@"MapView drawFrame e.name:%@,e.reason:%@",[e name],[e reason]]];
	}*/
	}
	
	
	//fire event
	if(movingJustDoneL){
		deCartaPosition * cp=[self getCenterPosition];
        
        if(movingListener){
            movingListener.callback(self,cp);
            //[movingListener release];
            //movingListener=nil;
        }
        
        [self executeEventListeners:MOVEEND withParam:cp];
	}
	if(zoomingJustDoneL){
		if(zoomingListener){
            zoomingListener.callback(self,[NSNumber numberWithFloat:_zoomLevel]);
            //[zoomingListener release];
            //zoomingListener=nil;
        }
        
        [self executeEventListeners:ZOOMEND withParam:[NSNumber numberWithFloat:_zoomLevel]];
	}
	
	if(rotatingZJustDoneL && _lastZRotation!=_mapMode.zRotation){
		[self executeEventListeners:ROTATEEND withParam:[NSNumber numberWithFloat:_mapMode.zRotation]];
	}
	
	if(rotatingXJustDoneL && _lastXRotation!=_mapMode.xRotation){
		[self executeEventListeners:TILTEND withParam:[NSNumber numberWithFloat:_mapMode.xRotation]];
	}
	
    [self presentFramebuffer];
	//[pool drain];
	
}


-(CGRect)getInfoWindowRect:(deCartaXYFloat *)screenXY{
	CGRect r=_infoWindow.rect;
	r.origin.x+=screenXY.x;
	r.origin.y+=screenXY.y;
	return r;
}

-(void)longTouchTask:(id)param
{
    @synchronized(_longTouchLock)
    {
        deCartaXYFloat *xy0Conv=[(NSTimer *)param userInfo];
        
        //[deCartaLogger debug:[NSString stringWithFormat:@"MapView longTouchTask xy0Conv:%@, _longClicked:%d, _longTouchTimer isValid:%d", xy0Conv, _longClicked, [_longTouchTimer isValid]]];
        
        if(![_longTouchTimer isValid]) return;
        
        _longClicked=true;
        deCartaPosition * pos;
        pos=[self screenXYConvToPos:xy0Conv.x y:xy0Conv.y];
        [self executeEventListeners:LONGTOUCH withParam:pos];
        
        [self resetLongTouchTimer];
    }
    
}

-(void)resetLongTouchTimer{
    @synchronized(_longTouchLock){
        //[deCartaLogger debug:[NSString stringWithFormat:@"MapView resetLongTouchTimer _longClicked:%d, _longTouchTimer isValid:%d", _longClicked, [_longTouchTimer isValid]]];
        [_longTouchTimer invalidate];
        [_longTouchTimer release];
        _longTouchTimer=nil;
    }
}

-(void)setupLongTouchTimer:(deCartaXYFloat *)xy0Conv {
    @synchronized(_longTouchLock){
        //[deCartaLogger debug:@"MapView setupLongTouchTimer"];
        
        _longTouchTimer=[[NSTimer scheduledTimerWithTimeInterval:LONG_TOUCH_TIME_MIN target:self selector:@selector(longTouchTask:) userInfo:xy0Conv repeats:NO] retain];
    }
}

@end



@implementation deCartaMapView
@synthesize zoomLevel=_zoomLevel;
@synthesize infoWindow=_infoWindow;
@synthesize radiusX=_radiusX,radiusY=_radiusY;
@synthesize displaySize=_displaySize;
@synthesize drawingLock=_drawingLock;
@synthesize touching=_touching;
@synthesize touchingLock=_touchingLock;
@synthesize movingLock=_movingLock;
@synthesize tileImages=_tileImages;
@synthesize tileTextureRefs=_tileTextureRefs;
@synthesize mapType=_mapType;
@synthesize compass=_compass;



- (id)initWithCoder:(NSCoder*)coder
{
    [deCartaLogger debug:@"MapView initWithCoder"];
	if ((self = [super initWithCoder:coder])) {
        // Initialization code
		[self initParams];
    }
	
    return self;
	
}

- (id)initWithFrame:(CGRect)frame {
	[deCartaLogger debug:@"MapView initWidthFrame"];
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self initParams];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [deCartaLogger debug:@"MapView dealloc"];
	
	[self deallocGLView];
	
	[_eventListeners release];
	
	[_overlays release];
	[_shapes release]; 
	[_infoWindow release];
	
	[_gridSize release];
	[_displaySize release];
	[_offset release];
    [_panDirection release];
	
	[_mapLayers release];
	
	[_tileImages release];
	[_tileTextureRefs release];
	[_iconPool release];
    [_clusterTextPool release];
	
	[_centerXYZ release];
	[_centerXY release];
	[_centerDelta release];
	
	[_lastCenterConv release];
	[_lastTouchConv release];
	[_lastTouch release];
	
	[_lastTouchDown release];
	[_lastTouchUp release];
	[_lastDirection release];
	[_lastTouchY release];
	
	[_mapMode release];	
	[_drawingLock release];
    [_touchingLock release];
    [_movingLock release];
	[_drawingTiles release];
	
	[_compass release];
	
	[_tileThreadPool release];
	
	freeTouchRecord(&_touchRecord1);
	freeTouchRecord(&_touchRecord2);
	freeEasingRecord(&_easingRecord);
	freeZoomingRecord(&_zoomingRecord);
    
    [_longTouchLock release];
    [_longTouchTimer release];
	
	[super dealloc];
}








-(void)refreshMap{
	@synchronized(_drawingLock){
		[self resumeView];
	}
}


-(void)changeMapType:(deCartaMapTypeEnum)mapType{
	if(_mapType==mapType) return;
	_mapType=mapType;
	
	@synchronized(_drawingLock){
		[self configureMapLayer];
		[self resumeView];
	}
}

-(void)rotateXToDegree:(float)xRotation{
	
	if(xRotation>0 || xRotation<MAP_TILT_MIN){
		[deCartaLogger warn:[NSString stringWithFormat:@"MapView rotateXToDegree:%f not in range 0 to %f",xRotation,MAP_TILT_MIN]];
		return;
		
	}
	@synchronized(_drawingLock){
		_mapMode.xRotating=true;
		_mapMode.xRotationEndTime=[NSDate timeIntervalSinceReferenceDate]+XROTATION_TIME*ABS((xRotation-_mapMode.xRotation)/MAP_TILT_MIN);
		_mapMode.xRotationEnd=xRotation;
		
		[self resumeView];
	}
}

-(void)rotateZToDegree:(float)zRotation{
	@synchronized(_drawingLock){
		zRotation=(((int)zRotation+180)%360+360)%360-180 +(zRotation-(int)zRotation);
		float diff=zRotation-_mapMode.zRotation;
		if(diff>180) diff-=360;
		else if(diff<-180) diff+=360;
		_mapMode.zRotating=true;
		_mapMode.zRotationEndTime=[NSDate timeIntervalSinceReferenceDate]+ZROTATION_TIME*ABS((diff)/180);
		_mapMode.zRotationEnd=zRotation;
		
		[self resumeView];
		
	}
}


-(deCartaMapPreferenceStruct *)getMapPreferenceRef{
	return &_mapPreference;
}

-(void)clearMap{
	[_overlays removeAllObjects];
	[_shapes removeAllObjects];
	_infoWindow.associatedPin=nil;
	_infoWindow.visible=FALSE;
	@synchronized(_drawingLock){
		[self resumeView];
	}
}



-(void)centerOnPosition:(deCartaPosition *)inPos{
	[self centerOnPosition:inPos zoomLevel:_zoomLevel host:nil];
}

-(void)centerOnPosition:(deCartaPosition *)inPos zoomLevel:(float)inZoomLevel host:(NSString *)specificHost{
	
	@synchronized(_drawingLock){
        @try{
            
            [_tileTextureRefs removeAllObjects];
            [_tileImages removeAllObjects];
            
            int z=round(inZoomLevel);
            deCartaXYDouble * centerXYL=[deCartaUtil posToMercPix:inPos atZoom:z];
            
            if([specificHost length]<=0){
                [deCartaWebServices setHostViaRUOK:g_config.host];
                [deCartaLogger info:[NSString stringWithFormat:@"MapView centerOnPosition setHostViaRUOK:%@",[deCartaWebServices getHost]]];
                
            }else {
                [deCartaWebServices setHost:specificHost];
                [deCartaLogger info:[NSString stringWithFormat:@"MapView centerOnPosition setHost using specificHost:%@",[deCartaWebServices getHost]]];
            }
            
            NSString * seedTileUrl=[deCartaUtil composeSeedTileUrl:[deCartaWebServices getHost]];
            
            [deCartaLogger info:[NSString stringWithFormat:@"MapView centerOnPosition seedTileUrl:%@",seedTileUrl]];
            
            
            deCartaTileGridResponse * resp=[deCartaUtil handlePortrayMapRequest:centerXYL atZ:z];
            resp.seedTileUrl=seedTileUrl;
            deCartaMapLayerProperty * streetMP=[deCartaMapLayerProperty getInstance:STREET];
            streetMP.templateSeedTileUrl=seedTileUrl;
            streetMP.sessionId=[deCartaUtil getSessionIdFromTileUrl:seedTileUrl];
            streetMP.configuration=[deCartaUtil getConfigurationFromTileUrl:seedTileUrl];
            deCartaMapLayerProperty * transparentMP=[deCartaMapLayerProperty getInstance:TRANSPARENT];
            transparentMP.templateSeedTileUrl=[deCartaUtil tileUrlToTransparent:seedTileUrl];
            transparentMP.sessionId=[deCartaUtil getSessionIdFromTileUrl:seedTileUrl];
            transparentMP.configuration=g_config.transparentConfiguration;
            
            _zoomLevel=inZoomLevel;
            [self renderMap:resp];
            
            
        }
        @catch (NSException * e) {
            [_overlays removeAllObjects];
            [_shapes removeAllObjects];
            _infoWindow.associatedPin=nil;
            [_centerXY release];
            _centerXY=nil;
            [deCartaMapLayerProperty getInstance:STREET].templateSeedTileUrl=nil;
            [deCartaMapLayerProperty getInstance:TRANSPARENT].templateSeedTileUrl=nil;
            [deCartaWebServices setHost:nil];
            @throw e;
        }
        
    }
    
    [self resumeView];
}

-(NSString *)getSpecificHost{
	return [deCartaWebServices getHost];
}


-(void)panToPosition:(deCartaPosition *)position{
	[self panToPosition:position duration:PAN_TO_POSITION_TIME_DEF listener:nil];
}

-(void)panToPosition:(deCartaPosition *)position duration:(double)duration listener:(deCartaEventListener *)listener{
	if(position==nil) return;
    
    
	
	BOOL moveJustDown=false;
	@synchronized(_drawingLock){
		if(_zoomingRecord.digitalZooming){
            [deCartaLogger warn:@"MapView panToPosition:duration:listener can't execute panToPosition when digitalZooming"];
            return;
        }
        
        [self resetEasingRecord:(&_easingRecord)];
		
        deCartaXYDouble * newMercXY=[deCartaUtil posToMercPix:position atZoom:_zoomLevel];
		double scale=pow(2,_zoomLevel-_centerXYZ.z);
		float x = (float)(_centerXY.x*scale - newMercXY.x);
		float y = (float)(newMercXY.y - _centerXY.y*scale);
		if(g_config.DECELERATE>0){
			_easingRecord.startMoveTime=[NSDate timeIntervalSinceReferenceDate];
			double s=sqrt(x*x+y*y);
			_easingRecord.direction.x=(float)(x/s);
			_easingRecord.direction.y=(float)(y/s);
			_easingRecord.decelerateRate=pow(_easingRecord.MINIMUM_SPEED_RATIO, _easingRecord.TIME_SCALE/duration);
			_easingRecord.speed=-s/_easingRecord.TIME_SCALE*log(_easingRecord.decelerateRate);
            
            [_easingRecord.listener release];
            _easingRecord.listener=[listener retain];
			
			[self resumeView];
			
		}else{
			[self moveViewX:x andY:y];
			moveJustDown=true;
		}
	}
	
	if(moveJustDown){
		listener.callback(self,position);
        
        [self executeEventListeners:MOVEEND withParam:position];
	}
	
}

-(deCartaPosition *)getCenterPosition{
	if(_centerXY ==nil) return nil;
	return [deCartaUtil mercPixToPos:_centerXY atZoom:_centerXYZ.z];
}

-(float)zRotation{
    return _mapMode.zRotation;
}

-(float)xRotation{
    return _mapMode.xRotation;
}

-(BOOL)moving{
    return _easingRecord.speed>0;
}

-(deCartaXYFloat *)positionToScreenXY:(deCartaPosition *)pos{
	deCartaXYFloat * xyConv=[self positionToScreenXYConv:pos];
	float xConv=xyConv.x-_displaySize.x/2;
	float yConv=xyConv.y-_displaySize.y/2;
	float cosZ=_mapMode.cosZ;
	float sinZ=_mapMode.sinZ;
	float xConv2=cosZ*xConv-sinZ*yConv;
	float yConv2=sinZ*xConv+cosZ*yConv;
	float cosX=_mapMode.cosX;
	float sinX=_mapMode.sinX;
	float y=yConv2*_mapMode.scale*cosX*_mapMode.nearZ/(_mapMode.middleZ+yConv2*_mapMode.scale*sinX);
	float x=xConv2*_mapMode.scale*_mapMode.nearZ/(_mapMode.middleZ+yConv2*_mapMode.scale*sinX);
	x+=_displaySize.x/2;
	y+=_displaySize.y/2;
	return [[[deCartaXYFloat alloc] initWithXf:x andYf:y] autorelease];
}

-(deCartaPosition *)screenXYToPos:(deCartaXYFloat *)screenXY{
	deCartaXYFloat * xyConv=[self screenXYToScreenXYConv:screenXY.x top:screenXY.y];
	return [self screenXYConvToPos:xyConv.x y:xyConv.y];
} 

-(void)setZoomLevel:(float)inZoomLevel{
	if (inZoomLevel < g_config.ZOOM_LOWER_BOUND && inZoomLevel > g_config.ZOOM_UPPER_BOUND) {
		@throw [NSException exceptionWithName:@"ZoomLevelOutOfRange" reason:@"Zoom level is out of range" userInfo:nil];
	}
	if(_centerXY ==nil || _displaySize==nil ||  _displaySize.x==0 || _displaySize.y==0)
		_zoomLevel = inZoomLevel;
	else {
		[self zoomViewTo:inZoomLevel atCenter:[deCartaXYFloat XYWithX:_displaySize.x/2.0f andY:_displaySize.y/2.0f]];
	}

}

-(void)zoomIn{
	double duration=DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(roundf(_zoomLevel)+1-_zoomLevel);
    
    [self zoomTo:roundf(_zoomLevel)+1 center:[deCartaXYFloat XYWithX:_displaySize.x/2.0 andY:_displaySize.y/2.0] duration:duration listener:nil];
	
}

-(void)zoomInAtPosition:(deCartaPosition *)zoomCenter{
	double duration=DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(roundf(_zoomLevel)+1-_zoomLevel);
    
    deCartaXYFloat * c=[self positionToScreenXYConv:zoomCenter];
	[self zoomTo:roundf(_zoomLevel)+1 center:c duration:duration listener:nil];
}

-(void)zoomOut{
	double duration=DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(roundf(_zoomLevel)-1-_zoomLevel);
    
    [self zoomTo:roundf(_zoomLevel)-1 center:[deCartaXYFloat XYWithX:_displaySize.x/2.0 andY:_displaySize.y/2.0] duration:duration listener:nil];
	
}

-(void)zoomOutAtPosition:(deCartaPosition *)zoomCenter{
	double duration=DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(roundf(_zoomLevel)-1-_zoomLevel);
    
    deCartaXYFloat * c=[self positionToScreenXYConv:zoomCenter];
	[self zoomTo:roundf(_zoomLevel)-1 center:c duration:duration listener:nil];
}

-(void)zoomTo:(int)inZ position:(deCartaPosition *)zoomCenter{
	double duration=DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(inZ-_zoomLevel);
    
    deCartaXYFloat * c=[self positionToScreenXYConv:zoomCenter];
	[self zoomTo:inZ center:c duration:duration listener:nil];
	
}

-(void)zoomTo:(int)inZ{
	double duration=DIGITAL_ZOOMING_TIME_PER_LEVEL*ABS(inZ-_zoomLevel);
    
    [self zoomTo:inZ center:[deCartaXYFloat XYWithX:_displaySize.x/2.0 andY:_displaySize.y/2.0] duration:duration listener:nil];
}

-(void)zoomTo:(int)inZ position:(deCartaPosition *)zoomCenter duration:(double)duration listener:(deCartaEventListener *)listener{
	deCartaXYFloat * c=[self positionToScreenXYConv:zoomCenter];
	[self zoomTo:inZ center:c duration:duration listener:listener];
	
}

-(void)zoomTo:(int)inZ duration:(double)duration listener:(deCartaEventListener *)listener{
	[self zoomTo:inZ center:[deCartaXYFloat XYWithX:_displaySize.x/2.0 andY:_displaySize.y/2.0] duration:duration listener:listener];
}

-(NSString *)getTemplateSeedTileUrl{
	return [deCartaMapLayerProperty getInstance:STREET].templateSeedTileUrl;
}

-(void)clearCachedTiles{
    [_tileThreadPool.tileCache clearCache];
}

-(void)waitForDrawDone{
    @synchronized(_drawingLock){}
}

#pragma mark -
#pragma mark @implementation overlay operation
-(void)addOverlay:(deCartaOverlay *)overlay{
	if(overlay==nil){
		[deCartaLogger warn:@"MapView addOverlay nil"];
		return;
	}
	
	for(deCartaOverlay * o in _overlays){
		if([o.name isEqual:overlay.name]){
			@throw [NSException exceptionWithName:@"DuplicateOverlayName" reason:@"Duplicate overlay name" userInfo:nil];
		}
	}
	[_overlays addObject:overlay];
}

	
-(void)deleteOverlayAtIndex:(int)index{
	[_overlays removeObjectAtIndex:index];
}
	
-(void)deleteOverlay:(deCartaOverlay *)overlay{
	[_overlays removeObject:overlay];
}

-(deCartaOverlay *)deleteOverlayByName:(NSString *)name{
	for(deCartaOverlay * o in _overlays){
		if([o.name isEqual:name]){
			[o retain];
			[_overlays removeObject:o];
			return [o autorelease];
		}
	}
	return nil;
}	
	
-(void)deleteOverlays{
	[_overlays removeAllObjects];
}
	
-(deCartaOverlay *)getOverlayByName:(NSString *)name{
	for(deCartaOverlay * o in _overlays){
		if([o.name isEqual:name]){
			return o;
		}
	}
	return nil;
}
	
-(deCartaOverlay *)getOverlay:(int)index{
	return [_overlays objectAtIndex:index];
}

-(void)hideOverlays{
	for(int i=0;i<[_overlays count];i++){
		deCartaOverlay * overlay=[_overlays objectAtIndex:i];
		for(int j=0;j<[overlay size];j++){
			[overlay getAtIndex:j].visible=FALSE;
		}
	}
}

-(void)showOverlays{
	for(int i=0;i<[_overlays count];i++){
		deCartaOverlay * overlay=[_overlays objectAtIndex:i];
		for(int j=0;j<[overlay size];j++){
			[overlay getAtIndex:j].visible=TRUE;
		}
	}
}

#pragma mark -
#pragma mark @implementation shape operation
-(int)getShapesSize{
	return [_shapes count];
}
	
-(deCartaShape *)getshapeAtIndex:(int)i{
	return [_shapes objectAtIndex:i];
}
	
-(deCartaShape *)getShapeByName:(NSString *)shapeName{
	for(int i=0;i<[_shapes count];i++){
		if ([[[_shapes objectAtIndex:i] name] isEqual:shapeName]) {
			return [_shapes objectAtIndex:i];
		}
	}
	return nil;
}
	
-(void)addShape:(deCartaShape *)shape{
	for(int i=0;i<[_shapes count];i++){
		if ([[[_shapes objectAtIndex:i] name] isEqual:shape.name]) {
			@throw [NSException exceptionWithName:@"DuplicateShapeName" reason:@"Duplicate shape name" userInfo:nil];
		}
	}
	[_shapes addObject:shape];
}

-(void)removeShapes{
	[_shapes removeAllObjects];
}

-(deCartaShape *)removeShapeAtIndex:(int)i{
	deCartaShape * shape=[[_shapes objectAtIndex:i] retain];
	[_shapes removeObjectAtIndex:i];
	return [shape autorelease];
	
}
-(void)removeShape:(deCartaShape *)shape;{
	[_shapes removeObject:shape];
}
	
-(deCartaShape *)removeShapeByName:(NSString *)shapeName{
	deCartaShape * shape=nil;
	for(int i=0;i<[_shapes count];i++){
		if ([[[_shapes objectAtIndex:i] name] isEqual:shapeName]) {
			shape= [[_shapes objectAtIndex:i] retain];
			[_shapes removeObjectAtIndex:i];
			break;
		}
	}
	return [shape autorelease];
}
	

#pragma mark -
#pragma mark @implementation EventSource protocol
-(BOOL)addEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	if([_eventListeners objectForKey:[NSNumber numberWithInt:eventType]]==nil){
		[_eventListeners setObject:[NSMutableArray arrayWithCapacity:1] forKey:[NSNumber numberWithInt:eventType]];
	}
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array addObject:listener];
		
	return TRUE;
}

-(void)removeEventListener:(deCartaEventListener *)listener forEventType:(int)eventType{
	NSMutableArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	[array removeObject:listener];
}

-(void)removeEventListeners:(int)eventType{
	[_eventListeners removeObjectForKey:[NSNumber numberWithInt:eventType]];
	 
}

-(void)executeEventListeners:(int)eventType withParam:(id)param{
	NSArray * array=[_eventListeners objectForKey:[NSNumber numberWithInt:eventType]];
	for(deCartaEventListener * listener in array){
		(listener.callback)(self,param);
	}
}

#pragma mark -
#pragma mark @implementation GLView operation


// You must implement this method

- (void)startAnimation
{
	[deCartaLogger debug:[NSString stringWithFormat:@"MapView startAnimation _animating:%d",_animating]];
	if (!_animating)
    {
        /*
		 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
		 */
		_displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
		[_displayLink setFrameInterval:1];
		
		// The run loop will retain the display link on add.
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
		_animating = TRUE;
    }
}

- (void)stopAnimation
{
	[deCartaLogger debug:[NSString stringWithFormat:@"MapView stopAnimation _animating:%d",_animating]];
	if (_animating)
	{
		[_displayLink invalidate];
		_displayLink = nil;
		
		_animating = FALSE;
	}
}


@end
