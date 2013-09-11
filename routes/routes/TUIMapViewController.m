//
//  TUIMapViewController.m
//  decarta
//
//  Created by Diego Lafuente on 22/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIAppDelegate.h"
#import "TUIMapViewController.h"
#import "TUILocationManager.h"
#import "TUIXploreViewController.h"
#import "config.h"

#pragma mark - Private interface
@interface TUIMapViewController () <TUILocationManagerDelegate, UISplitViewControllerDelegate, TUISpotDelegate, TUIXploreViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet deCartaMapView *mapView;
@property (strong, nonatomic) deCartaOverlay *routeSpots;
@property (strong, nonatomic) deCartaRoutePreference *routePrefs;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *routeBarButton;
/****CRAP FOR NAVIGATION****/
@property (strong, nonatomic) NSUserDefaults *persist;
/****CRAP FOR NAVIGATION****/

-(IBAction)routeBarClicked:(UIBarButtonItem *)sender;
-(IBAction)playButtonClicked:(UIButton *)sender;

/**
 * Adds event listeners to the map
 */
-(void)addMapEventListeners;
/**
 * Removes event listeners from the map
 */
-(void)removeMapEventListeners;
/**
 * Updates routeButton label based on the state of the map
 */
-(void)refreshRouteBarButton;
/**
 * Calculates the route based on the points in _routePins
 */
-(void)calculateRouteWithCompletionHandler:(void (^)(NSError *error, deCartaRoute *route))completionHandler;
/**
 * Removes pins and routes from the map
 */
-(void)resetMap;
/**
 * Checks if a deCarta position is out of bounds
 */
-(BOOL)isOutOfBounds:(deCartaPosition *)position;
/**
 * Generates an array of deCartaPosition from _routeSpots
 */
-(NSArray *)getSpotPositions;


@end

#pragma mark - Implementation
@implementation TUIMapViewController

#pragma mark - Public Methods
-(void)closeMaster {
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

-(TUISpot *)addSpotOfType:(TUISpotType)type
             withLatitude:(double)latitude
                longitude:(double)longitude
                  andName:(NSString *)name {
    deCartaPosition *position = [[deCartaPosition alloc] initWithLat:latitude andLon:longitude];
    TUISpot *spot = [[TUISpot alloc] initSpotOfType:type withPosition:position andName:name];
    [spot setDelegate:self];
    [_routeSpots addPin:spot];
    [self refreshRouteBarButton];
    if ([self isOutOfBounds:position]) { //the pin is out of bounds
        NSArray *positions = [self getSpotPositions];
        deCartaBoundingBox *boundingBox = [deCartaUtil getBoundingBoxFromPositions:positions];
        int zoom=[deCartaUtil getZoomLevelToFitBoundingBox:boundingBox withDisplaySize:_mapView.displaySize];
        [_mapView setZoomLevel:zoom];
        //Pan the map to center on the center of the route
        [_mapView panToPosition:[boundingBox getCenterPosition]];
    }
    [_mapView refreshMap];
    return spot;
}
-(void)removeSpot:(TUISpot *)spot {
    [_routeSpots removePin:spot];
    [self refreshRouteBarButton];
    [_mapView refreshMap];
}

#pragma mark - Private Methods
-(void)addMapEventListeners {
    //Capture MOVEEND
    [_mapView addEventListener:[deCartaEventListener eventListenerWithCallback:^(id<deCartaEventSource> sender, deCartaPosition *position) {
        NSLog(@"Moved!! - Lat: %f - Lon: %f", position.lat, position.lon);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:position.lat longitude:position.lon];
        [[TUILocationManager sharedInstance] storeMapCenter:location];
    }] forEventType:MOVEEND];
    //Capture LONGTOUCH
    [_mapView addEventListener:[deCartaEventListener eventListenerWithCallback:^(id<deCartaEventSource> sender, deCartaPosition *position) {
        NSLog(@"LongTouch!! - Lat: %f - Lon: %f", position.lat, position.lon);
        [self addSpotOfType:TUICustomSpot withLatitude:position.lat longitude:position.lon andName:@"Custom Location"];
    }] forEventType:LONGTOUCH];
}

-(void)removeMapEventListeners {
    //Remove MOVEEND
    [_mapView removeEventListeners:MOVEEND];
    //Remove LONGTOUCH
    [_mapView removeEventListeners:LONGTOUCH];
}

- (IBAction)routeBarClicked:(UIBarButtonItem *)sender {
    //Is it route or reset?
    if ([_routeBarButton.title isEqualToString:@"Route"]){
        //remove previous route
        [_mapView removeShapes];
        //create activity indicator
        __block UIActivityIndicatorView  *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake((self.view.frame.size.width/2)-10, (self.view.frame.size.height/2)-10, 20, 20);
        //dim view
        self.view.alpha = 0.5;
        [self.view addSubview:indicator];
        [indicator startAnimating];
        //calculate route
        [self calculateRouteWithCompletionHandler:^(NSError *error, deCartaRoute *route) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:error.domain
                                      message: error.userInfo[@"message"]
                                      delegate: nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil];
                alert.cancelButtonIndex = -1;
                [alert show];
            } else {
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                self.view.alpha = 1;
                deCartaPolyline *routeLine=[[deCartaPolyline alloc] initWithPositions:route.routeGeometry name:@"route"];
                [_mapView addShape:routeLine];
                //Zoom the map to a scale which can display the whole route
                int zoom=[deCartaUtil getZoomLevelToFitBoundingBox:route.boundingBox withDisplaySize:_mapView.displaySize];
                [_mapView setZoomLevel:zoom];
                //Pan the map to center on the center of the route
                [_mapView panToPosition:[route.boundingBox getCenterPosition]];
                [_mapView refreshMap];
                [_routeBarButton setTitle:@"Reset"];
                [_delegate disableCells:YES];
                [self removeMapEventListeners];
                _playButton.hidden = NO;
            }
        }];
    } else {
        [_delegate aboutToRemoveAllSpots];
        //reset map
        [self resetMap];
    }
}

- (IBAction)playButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showNavigation" sender:self];
    //[self performSegueWithIdentifier:@"showFakeNavigation" sender:self];
}

-(void)refreshRouteBarButton {
    NSString *title = @"Reset";
    if ([_routeSpots size] > 1) {
        title = @"Route";
    }
    [_routeBarButton setTitle:title];
}

-(void)calculateRouteWithCompletionHandler:(void (^)(NSError *error, deCartaRoute *route))completionHandler {
    NSRunLoop *completionRunLoop = [NSRunLoop currentRunLoop];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        //Calculate a route with the available pins in the overlay
        NSArray *routePositions = [self getSpotPositions];
        deCartaRoute * route=[deCartaRouteQuery query:routePositions routePreference:_routePrefs];
        if (!route) {
            error = [NSError errorWithDomain:@"ROUTE_ERROR" code:1001 userInfo:@{@"message":@"Server error: couldn't calculate route"}];
        }
        CFRunLoopRef nativeRunLoop = [completionRunLoop getCFRunLoop];
        CFRunLoopPerformBlock(nativeRunLoop,
                              kCFRunLoopDefaultMode,
                              ^(void) {
                                  completionHandler(error, route);
                              });
        CFRunLoopWakeUp(nativeRunLoop);
    });
}

-(void)resetMap {
    //remove all pins from the overlay
    [_routeSpots clear];
    //add event listeners
    [self addMapEventListeners];
    //remove the route if existed
    [_mapView removeShapes];
    deCartaPosition *position = [[TUILocationManager sharedInstance] getHomeLocation];
    [_mapView centerOnPosition:position];
    _mapView.zoomLevel= [[TUILocationManager sharedInstance] getZoomLevel];
    [self addSpotOfType:TUIHomeSpot withLatitude:position.lat longitude:position.lon andName:@"Home, sweet home"];
    _playButton.hidden = YES;
    //[_mapView refreshMap];
    [_mapView startAnimation];
}

-(BOOL)isOutOfBounds:(deCartaPosition *)position {
    deCartaXYFloat *screenPosition = [_mapView positionToScreenXY:position];
    deCartaXYInteger *bounds = [_mapView displaySize];
    if (screenPosition.x < 0 ||
        screenPosition.y < 0 ||
        screenPosition.x > bounds.x ||
        screenPosition.y > bounds.y) {
        return YES;
    }
    return NO;
}

-(NSArray *)getSpotPositions {
    NSMutableArray *result = [NSMutableArray array];
    //start point
    [result addObject:[[_routeSpots getAtIndex:0] position]];
    for(int i=1; i<[_routeSpots size]; i++) {
        [result addObject:[[_routeSpots getAtIndex:i] position]];
    }
    //end point
    [result addObject:[[_routeSpots getAtIndex:0] position]];
    return result;
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
    _routeSpots = [[deCartaOverlay alloc] initWithName:@"route_spots"];
    [_mapView rotateXToDegree:0];
    [_mapView addOverlay:_routeSpots];
    [_mapView showOverlays];
    _routePrefs = [[deCartaRoutePreference alloc] init];
    _routePrefs.style=@"Fastest";
    [self resetMap];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //place the play button properly
    _playButton.center = _mapView.center;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //repaint the map
    [_mapView refreshMap];
    [_mapView startAnimation];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showNavigation"]) {
        //Configure the navigation session
        DCNavigationConfig		*navigationConfig = [DCNavigationConfig configWithServer:@"chameleon-dev1.decarta.com"];
        [navigationConfig populateDefaults];
        navigationConfig.resourceDir = [NSString stringWithFormat:@"%@/nav_resources", [[NSBundle mainBundle] resourcePath]];
        DCNavigationManager *navigation;
        navigation = [(TUIAppDelegate *)[[UIApplication sharedApplication] delegate] beginNavigationSessionWithConfig:navigationConfig];
        //TODO: Configure guidance. Can I do all this in TUIXploreViewController
        DCGuidanceConfig *guidanceConfig;
        CLLocationCoordinate2D origin, destination;
        NSArray *routeSpots = [self getSpotPositions];
        origin.latitude = [(deCartaPosition *)routeSpots[0] lat];
        origin.longitude = [(deCartaPosition *)routeSpots[0] lon];
        destination.latitude = [(deCartaPosition *)routeSpots[1] lat];;
        destination.longitude = [(deCartaPosition *)routeSpots[1] lon];;
        guidanceConfig = [DCGuidanceConfig configWithDestination:destination origin:origin];
        //guidanceConfig = [DCGuidanceConfig configWithDestination:destination];
		guidanceConfig.simulationSpeed = 5;
        guidanceConfig.units = DCGuidanceUnitsMetric;
        guidanceConfig.routeMode = DCGuidanceRouteModeCarpool;
        guidanceConfig.routeOptionMask = 0;
        guidanceConfig.sensorLogPath = nil;
        guidanceConfig.simulate = YES;
        //Configure navViewController
        TUIXploreViewController *navViewController = (TUIXploreViewController *)segue.destinationViewController;
        navViewController.routeSpots = _routeSpots;
        navViewController.delegate = self;
        navViewController.guidanceConfig = guidanceConfig;
        
        // Run navigation
        [navigation configureGuidance:guidanceConfig];
        [navigation runGuidance];
    } 
    
    [_delegate performedSegue:segue.identifier];
}

#pragma mark - TUILocationManagerDelegate Methods
-(void)userLocationReady:(CLLocation *)location {
    deCartaPosition *position = [[deCartaPosition alloc] initWithLat:location.coordinate.latitude andLon:location.coordinate.longitude];
    [_mapView centerOnPosition:position];
    _mapView.zoomLevel= [[TUILocationManager sharedInstance] getZoomLevel];
    [_mapView refreshMap];
    [_mapView startAnimation];
}

#pragma mark - TUISpotDelegate Methods
-(void)spotTouched:(TUISpot *)sender {
    //display the infoWindow
    deCartaInfoWindow * infoWindow = _mapView.infoWindow;
    infoWindow.associatedPin = sender;
    infoWindow.position=sender.position;
    infoWindow.message=sender.message;
    [infoWindow setOffset:[deCartaXYFloat XYWithX:0 andY:sender.icon.offset.y] andRotationTilt:sender.rotationTilt];
    infoWindow.visible=TRUE;
}

#pragma mark - TUINavViewControllerDelegate Methods
-(void)closeButtonClicked {
    [self dismissViewControllerAnimated:YES completion:^{}];
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
