//
//  TUIMapViewController.m
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIMapViewController.h"
#import "TUILocationManager.h"
#import "config.h"

#pragma mark - Private interface
@interface TUIMapViewController () <TUILocationManagerDelegate, UISplitViewControllerDelegate, TUIPinDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet deCartaMapView *mapView;
@property (strong, nonatomic) deCartaOverlay *routePins;
@property (strong, nonatomic) deCartaRoutePreference *routePrefs;
//TODO: put the route button in the bar
@property (strong, nonatomic) IBOutlet UIButton *routeButton;

-(IBAction)routeClicked:(id)sender;
/**
 * Adds event listeners to the map
 */
-(void)addMapEventListeners;
/**
 * Updates routeButton label based on the state of the map
 */
-(void)refreshRouteButton;
/**
 * Calculates the route based on the points in _routePositions
 */
-(void)calculateRoute;
/**
 * Removes pins and routes from the map
 */
-(void)resetMap;
-(void)logCurrentPins;

@end

#pragma mark - Implementation
@implementation TUIMapViewController

#pragma mark - Public Methods
-(void)closeMaster {
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

-(TUIPin *)addPinWithLatitude:(double)latitude
                    longitude:(double)longitude
                   andMessage:(NSString *)message {
    UIImage *pinImage = [UIImage imageNamed:@"pin.png"];
    /*int width = pinImage.size.width;
    int height = pinImage.size.height;
    deCartaXYInteger *size = [deCartaXYInteger XYWithX:width andY:height];
    deCartaXYInteger *offset = [deCartaXYInteger XYWithX:width/2 andY:height];
    deCartaIcon *pinicon = [[deCartaIcon alloc] initWithImage:pinImage size:size offset:offset];*/
    deCartaRotationTilt *pinrt=[[deCartaRotationTilt alloc] initWithRotateRelative:ROTATE_RELATIVE_TO_SCREEN tiltRelative:TILT_RELATIVE_TO_SCREEN];
    pinrt.rotation = 0.0; //No rotation
    pinrt.tilt = 0.0; //No tilt
    deCartaPosition *position = [[deCartaPosition alloc] initWithLat:latitude andLon:longitude];
    //deCartaPin * pin=[[deCartaPin alloc] initWithPosition:position icon:pinicon message:@"You fuck my mother" rotationTilt:pinrt];
    TUIPin *pin = [[TUIPin alloc] initWithPosition:position image:pinImage message:message andRotationTilt:pinrt];
    [pin setDelegate:self];
    [_routePins addPin:pin];
    [self refreshRouteButton];
    [_mapView refreshMap];
    [self logCurrentPins];
    return pin;
}
-(void)removePin:(TUIPin *)pin {
    [_routePins removePin:pin];
    [self refreshRouteButton];
    [_mapView refreshMap];
    [self logCurrentPins];
}

#pragma mark - Private Methods
-(void)addMapEventListeners {
    //Capture MOVEEND
    [_mapView addEventListener:[deCartaEventListener eventListenerWithCallback:^(id<deCartaEventSource> sender, deCartaPosition *position) {
        NSLog(@"Moved!! - Lat: %f - Lon: %f", position.lat, position.lon);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:position.lat longitude:position.lon];
        [[TUILocationManager sharedInstance] setUserLocation:location];
    }] forEventType:MOVEEND];
    //Capture LONGTOUCH
    [_mapView addEventListener:[deCartaEventListener eventListenerWithCallback:^(id<deCartaEventSource> sender, deCartaPosition *position) {
        NSLog(@"LongTouch!! - Lat: %f - Lon: %f", position.lat, position.lon);
        [self addPinWithLatitude:position.lat longitude:position.lon andMessage:@"User custom location"];
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
    if ([_routePins size] > 1) {
        title = @"Route";
    }
    [_routeButton setTitle:title forState:UIControlStateNormal];
}

-(void)calculateRoute {
    //Calculate a route with the available pins in the overlay
    NSMutableArray *routePositions = [NSMutableArray array];
    for (int i=0; i<[_routePins size]; i++) {
        [routePositions addObject:[[_routePins getAtIndex:i] position]];
    }
    deCartaRoute * route=[deCartaRouteQuery query:routePositions routePreference:_routePrefs];
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
    //remove the route if existed
    [_mapView removeShapes];
    [_mapView refreshMap];
}

-(void)logCurrentPins {
    NSLog(@"There are %d pins:", [_routePins size]);
    for(int i=0; i<[_routePins size]; i++) {
        NSLog(@"Latitude: %f - Longitude: %f", [[[_routePins getAtIndex:i] position] lat], [[[_routePins getAtIndex:i] position] lon]);
    }
}

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
    [_mapView rotateXToDegree:-45];
    [_mapView addOverlay:_routePins];
    [_mapView showOverlays];
    _routePrefs = [[deCartaRoutePreference alloc] init];
    _routePrefs.style=@"Fastest";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Get the user location. Dont do in OFFLINE mode
    if (!TEST_OFFLINE) {
        [[TUILocationManager sharedInstance] getUserLocation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TUILocationManagerDelegate Methods
-(void)locationReady:(CLLocation *)location {
    deCartaPosition *position = [[deCartaPosition alloc] initWithLat:location.coordinate.latitude andLon:location.coordinate.longitude];
    [_mapView centerOnPosition:position];
    _mapView.zoomLevel=13;
    [_mapView refreshMap];
    [_mapView startAnimation];
}

#pragma mark - TUIPinDelegate Methods
-(void)pinTouched:(TUIPin *)sender {
    //display the infoWindow
    deCartaInfoWindow * infoWindow = _mapView.infoWindow;
    infoWindow.associatedPin = sender;
    infoWindow.position=sender.position;
    infoWindow.message=sender.message;
    [infoWindow setOffset:[deCartaXYFloat XYWithX:0 andY:sender.icon.offset.y] andRotationTilt:sender.rotationTilt];
    infoWindow.visible=TRUE;
}

-(void)pinLongTouched:(TUIPin *)sender {
    //Tell master view to uncheck cell
    [_delegate aboutToRemovePin:sender];
    //remove pin
    [self removePin:sender];
    //Uncheck master list if needed
}

#pragma mark - UISplitViewControllerDelegate Methods

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Spots", @"Spots");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
