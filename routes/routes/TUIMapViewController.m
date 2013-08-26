//
//  TUIMapViewController.m
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIMapViewController.h"
#import "TUILocationManager.h"

#pragma mark - Private interface
@interface TUIMapViewController () <TUILocationManagerDelegate>

@property (strong, nonatomic) IBOutlet deCartaMapView *mapView;
@property (strong, nonatomic) deCartaOverlay *routePins;
@property (strong, nonatomic) NSMutableArray *routePositions;
@property (strong, nonatomic) deCartaRoutePreference *routePrefs;
@property (strong, nonatomic) IBOutlet UIButton *routeButton;

-(void)addMapEventListeners;
-(IBAction)routeClicked:(id)sender;
-(void)refreshRouteButton;
-(void)calculateRoute;
-(void)resetMap;

@end

#pragma mark - Implementation
@implementation TUIMapViewController

#pragma mark - UIViewController Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[TUILocationManager sharedInstance] addDelegate:self];
    [self addMapEventListeners];
    _routePins = [[deCartaOverlay alloc] initWithName:@"route_pins"];
    _routePositions = [NSMutableArray array];
    [_mapView rotateXToDegree:-45];
    [_mapView addOverlay:_routePins];
    [_mapView showOverlays];
    _routePrefs = [[deCartaRoutePreference alloc] init];
    _routePrefs.style=@"Fastest";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Get the user location.
    [[TUILocationManager sharedInstance] getUserLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
-(void)addMapEventListeners {
    //Capture MOVEEND
    [_mapView addEventListener:[deCartaEventListener eventListenerWithCallback:^(id<deCartaEventSource> es, deCartaPosition *position) {
        NSLog(@"Moved!! - Lat: %f - Lon: %f", position.lat, position.lon);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:position.lat longitude:position.lon];
        [[TUILocationManager sharedInstance] setUserLocation:location];
    }] forEventType:MOVEEND];
    //Capture LONGTOUCH
    [_mapView addEventListener:[deCartaEventListener eventListenerWithCallback:^(id<deCartaEventSource> es, deCartaPosition *position) {
        NSLog(@"LongTouch!! - Lat: %f - Lon: %f", position.lat, position.lon);
        UIImage *pinImage = [UIImage imageNamed:@"pin.png"];
        int width = pinImage.size.width;
        int height = pinImage.size.height;
        deCartaXYInteger *size = [deCartaXYInteger XYWithX:width andY:height];
        deCartaXYInteger *offset = [deCartaXYInteger XYWithX:width/2 andY:height];
        deCartaIcon *pinicon = [[deCartaIcon alloc] initWithImage:pinImage size:size offset:offset];
        deCartaRotationTilt *pinrt=[[deCartaRotationTilt alloc] initWithRotateRelative:ROTATE_RELATIVE_TO_SCREEN tiltRelative:TILT_RELATIVE_TO_SCREEN];
        pinrt.rotation = 0.0; //No rotation
        pinrt.tilt = 0.0; //No tilt
        deCartaPin * pin=[[deCartaPin alloc] initWithPosition:position icon:pinicon message:@"You fuck my mother" rotationTilt:pinrt];
        [_routePins addPin:pin];
        [_routePositions addObject:position];
        [self refreshRouteButton];
        [_mapView refreshMap];
    }] forEventType:LONGTOUCH];
}

-(IBAction)routeClicked:(id)sender {
    //Is it route or reset?
    if ([_routeButton.titleLabel.text isEqualToString:@"Route"]){
        //remove previous route
        [_mapView removeShapes];
        //calculate route
        [self calculateRoute];
        [_routeButton setTitle:@"Reset" forState:UIControlStateNormal];
    } else {
        //reset map
        [self resetMap];
    }
    
}

-(void)refreshRouteButton {
    NSString *title = @"Reset";
    if (_routePositions.count > 1) {
        title = @"Route";
    }
    [_routeButton setTitle:title forState:UIControlStateNormal];
}

-(void)calculateRoute {
    //Calculate a route with the available pins in the overlay
    deCartaRoute * route=[deCartaRouteQuery query:_routePositions routePreference:_routePrefs];
    if (route) {
        deCartaPolyline *routeLine=[[deCartaPolyline alloc] initWithPositions:route.routeGeometry name:@"route"];
        [_mapView addShape:routeLine];
        //Zoom the map to a scale which can display the whole route
        int zoom=[deCartaUtil getZoomLevelToFitBoundingBox:route.boundingBox withDisplaySize:_mapView.displaySize];
        [_mapView setZoomLevel:zoom];
        //Pan the map to center on the center of the route
        [_mapView panToPosition:[route.boundingBox getCenterPosition]];
        [_mapView refreshMap];
    }
}

-(void)resetMap {
    //remove all pins from the overlay
    [_routePins clear];
    [_routePositions removeAllObjects];
    //remove the route if existed
    [_mapView removeShapes];
    [_mapView refreshMap];
}

#pragma mark - TUILocationManagerDelegate Methods
-(void)locationReady:(CLLocation *)location {
    deCartaPosition *position = [[deCartaPosition alloc] initWithLat:location.coordinate.latitude andLon:location.coordinate.longitude];
    [_mapView centerOnPosition:position];
    _mapView.zoomLevel=13;
    [_mapView refreshMap];
    [_mapView startAnimation];
}

@end
