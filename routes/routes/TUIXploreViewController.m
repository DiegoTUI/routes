//
//  TUINavViewController.m
//  routes
//
//  Created by Diego Lafuente on 02/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIXploreViewController.h"
#import "TUIAppDelegate.h"
#import "NavigationCornerView.h"
#import "FormatUtils.h"
#import "UIImage+Tui.h"
#import "PinInfoView.h"
#import "TUIRouteController.h"

typedef enum RemainingDisplay {
	REMAINING_DISPLAY_TIME,
	REMAINING_DISPLAY_DISTANCE,
	REMAINING_DISPLAY_ARRIVAL,
	
	REMAINING_DISPLAY_COUNT
} RemainingDisplay;

#pragma mark - Private interface
@interface TUIXploreViewController () <DCMapDelegate, DCNavigationDelegate, DCMapPushpinDelegate, CornerViewDelegate, PinInfoViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
// Navigation manager and updates
@property (strong, nonatomic) DCNavigationManager *navigation;
@property (strong, nonatomic) id navigationUpdateConnection;
@property (strong, nonatomic) DCNavigationUpdate *lastUpdate;
// Used for managing the UI
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *resetPositionBarButton;
@property (weak, nonatomic) IBOutlet NavigationCornerView *destinationCornerView;
@property (weak, nonatomic) IBOutlet NavigationCornerView *nextManeuverCornerView;
@property (nonatomic) BOOL navigationActive;
@property (strong,nonatomic) id<DCGuidanceIcon> currentIcon;
@property (nonatomic) NSInteger remainingDisplayType;
@property (strong, nonatomic) NSMutableDictionary *droppedPins;
@property (strong, nonatomic) PinInfoView *activePinInfoView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (nonatomic) BOOL infoViewDisplayed;
@property (strong, nonatomic) NSLayoutConstraint *mapViewLeftConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *muteButton;
@property (strong, nonatomic) IBOutlet UIStepper *zoomStepper;

- (void)setLayoutConstraints;
- (void)updateRemainingDisplay;
- (IBAction)stopButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)resetPositionBarButtonClicked:(UIBarButtonItem *)sender;
- (void)closeActivePinInfoView;
- (IBAction)infoButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)muteButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)zoomStepperClicked:(UIStepper *)sender;

@end

#pragma mark - Implementation
@implementation TUIXploreViewController

#pragma mark - Private methods
- (void)setLayoutConstraints {
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_infoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSArray *verticalInfoViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(44)-[view]-(44)-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{@"view":_infoView}];
    NSArray *horizontalInfoViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view(259)]"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:@{@"view":_infoView}];
    NSArray *verticalMapViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(44)-[view]-(44)-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"view":mapView}];
    NSArray *horizontalMapViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]-(0)-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"view":mapView}];
    _mapViewLeftConstraint = horizontalMapViewConstraints[0];
    
    [self.view addConstraints:verticalInfoViewConstraints];
    [self.view addConstraints:horizontalInfoViewConstraints];
    [self.view addConstraints:verticalMapViewConstraints];
    [self.view addConstraints:horizontalMapViewConstraints];
    
}

- (void)setNavigationActive:(BOOL)isActive {
	if (isActive != _navigationActive) {
		if (isActive) {
			_destinationCornerView.hidden = NO;
            _nextManeuverCornerView.hidden = NO;
		}
		else {
			_destinationCornerView.hidden = YES;
            _nextManeuverCornerView.hidden = YES;
		}
		_navigationActive = isActive;
	}
}

- (void)updateRemainingDisplay {
	NSAttributedString	*display = nil;
    
	switch (_remainingDisplayType)
	{
        case REMAINING_DISPLAY_TIME:
            display = [FormatUtils formatTimeRemaining:_destinationCornerView.lblText seconds:_navigation.lastGuidance.secondsToArrival];
            break;
            
        case REMAINING_DISPLAY_DISTANCE:
            display = [FormatUtils formatDistance:_destinationCornerView.lblText meters:_navigation.lastGuidance.distanceToDestination imperial:NO];
            break;
            
        case REMAINING_DISPLAY_ARRIVAL:
            display = [FormatUtils formatArrivalTime:_destinationCornerView.lblText seconds:_navigation.lastGuidance.secondsToArrival];
            break;
	}
    
	_destinationCornerView.lblText.attributedText = display;
}

- (IBAction)stopButtonClicked:(UIBarButtonItem *)sender {
    [_navigation cancelGuidance];
    [self setNavigationActive:NO];
    [self clearRoute];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TUICloseNavigation"
     object:self];
}

- (IBAction)resetPositionBarButtonClicked:(UIBarButtonItem *)sender {
    [self setNavigationCameraActive:YES];
}

- (void)closeActivePinInfoView {
    [_activePinInfoView close];
	_activePinInfoView = nil;
}

- (IBAction)infoButtonClicked:(UIBarButtonItem *)sender {
    //toggle info window
    _mapViewLeftConstraint.constant = _infoViewDisplayed ? 0.0f : _infoView.bounds.size.width;
    NSString *title = _infoViewDisplayed ? @"Show info" : @"Close info";
    
    [UIView animateWithDuration:0.25f animations:^{
        [mapView layoutIfNeeded];
    }];

    _infoBarButton.title = title;
    _infoViewDisplayed = !_infoViewDisplayed;
}

- (IBAction)muteButtonClicked:(UIBarButtonItem *)sender {
    _navigation.audioMuted = !_navigation.audioMuted;
    sender.title = _navigation.audioMuted ? @"Sound on" : @"Mute";
}

- (IBAction)zoomStepperClicked:(UIStepper *)sender {
    const int stepperValue = (int)sender.value;
    
	if (stepperValue != mapView.zoomLevel) {
		BOOL zoomIn = (stepperValue - mapView.zoomLevel > 0);
		
		[mapView zoomStep:zoomIn];
		sender.value = mapView.zoomLevel;
	}
}

#pragma mark - UIViewController methods
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
    //Configure the navigation session
    DCNavigationConfig		*navigationConfig = [DCNavigationConfig configWithServer:@"chameleon-dev1.decarta.com"];
    [navigationConfig populateDefaults];
    navigationConfig.resourceDir = [NSString stringWithFormat:@"%@/nav_resources", [[NSBundle mainBundle] resourcePath]];
    _navigation = [(TUIAppDelegate *)[[UIApplication sharedApplication] delegate] beginNavigationSessionWithConfig:navigationConfig];
    DCGuidanceConfig *guidanceConfig;
    CLLocationCoordinate2D origin, dest;
    origin.latitude = [[[TUIRouteController sharedInstance] startSpot] latitude];
    origin.longitude = [[[TUIRouteController sharedInstance] startSpot] longitude];
    dest.latitude = [[[TUIRouteController sharedInstance] nextSpot:NO] latitude];
    dest.longitude = [[[TUIRouteController sharedInstance] nextSpot:NO] longitude];
    guidanceConfig = [DCGuidanceConfig configWithDestination:dest origin:origin];
    guidanceConfig.simulationSpeed = 5;
    guidanceConfig.units = DCGuidanceUnitsMetric;
    guidanceConfig.routeMode = DCGuidanceRouteModeCarpool;
    guidanceConfig.routeOptionMask = 0;
    guidanceConfig.sensorLogPath = nil;
    guidanceConfig.simulate = YES;
    
    // Run navigation
    [_navigation configureGuidance:guidanceConfig];
    [_navigation runGuidance];
    
    _droppedPins = [NSMutableDictionary dictionary];
	// Do any additional setup after loading the view.
    DCMapLaunchState *mapLaunchState = [[DCMapLaunchState alloc] init];
	DCNavLaunchState *navLaunchState = [[DCNavLaunchState alloc] initWithVehiclePositon:guidanceConfig.origin direction:0];
    
    navLaunchState.beginActive = YES;
	navLaunchState.beginNorthUp = NO;
	navLaunchState.beginOverhead = NO;
	navLaunchState.autoNightMode = NO;
	self.launchState = navLaunchState;
    
    mapLaunchState.mapProperties = nil;
	mapLaunchState.configProperties = nil;
	mapLaunchState.loggingProperties = nil;
	mapView.launchState = mapLaunchState;
    
    mapView.persistKey = @"routes";
    
	_navigationUpdateConnection = [_navigation registerForNavigationUpdatesWithDelegate:self];
    
    [self updateVehiclePosition:guidanceConfig.origin direction:0];
	[self setNavigationCameraActive:YES];
	//[self setDestination:guidanceConfig.destination];
    
    _destinationCornerView.imgIcon.image = [UIImage imageNamed:@"geo_resources/flag_icon.png"];
    [_destinationCornerView setDelegate:self];
    
    _statusLabel.text = @"Initializing...";
    
    _navigation.audioMuted = NO;
	_navigationActive = NO;
    _remainingDisplayType = 0;
    
    [self setLayoutConstraints];
    
    _infoViewDisplayed = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    //mapView.uiMargins = self.view.frame;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DCNavViewController overrides
- (void)navigationCameraBecameActive:(BOOL)active {
	[super navigationCameraBecameActive:active];
    
	_resetPositionBarButton.enabled = !active && self.vehiclePositionValid;
}

#pragma mark - CornerViewDelegate methods
- (void)cornerViewPressed:(NavigationCornerView *)sender {
    _remainingDisplayType = (_remainingDisplayType + 1) % REMAINING_DISPLAY_COUNT;
    [self updateRemainingDisplay];
}

#pragma mark - DCMapDelegate methods
- (void)doneLoading:(DCMapView *)mv {
	[super doneLoading:mv];
    
	_zoomStepper.value = mv.zoomLevel;
	const int	maneuverIconDim = _nextManeuverCornerView.imgIcon.frame.size.width;
	UIColor		*inactiveColor = [DCNavViewController maneuverIconDefaultInactiveColor];
	int			retinaFactor = [[UIScreen mainScreen] scale] - 1;
	
	[self configureManeuverIconsWithSize:(maneuverIconDim << retinaFactor) colorImages:NO dualLayered:NO inactiveColor:inactiveColor];
    //add pins to the map
    CLLocationCoordinate2D pinPosition;
    pinPosition.latitude = [[[TUIRouteController sharedInstance] startSpot] latitude];
    pinPosition.longitude = [[[TUIRouteController sharedInstance] startSpot] longitude];
    DCMapPushpin *pin = [[DCMapPushpin alloc]initWithMap:mv location:pinPosition initiallyVisible:YES];
    [pin setDelegate:self];
    [pin setFlagWithColor:[UIColor greenColor]];
    [_droppedPins setValue:pin forKey:[[[TUIRouteController sharedInstance] startSpot] message]];
    TUISpot *spot = [[TUIRouteController sharedInstance] nextSpot:YES];
    while (spot) {
        if (spot.type == TUIAttractionSpot){
            pinPosition.latitude = spot.latitude;
            pinPosition.longitude = spot.longitude;
            DCMapPushpin *pin = [[DCMapPushpin alloc]initWithMap:mv location:pinPosition initiallyVisible:YES];
            [pin setDelegate:self];
            [pin setFlagWithColor:[UIColor redColor]];
            [_droppedPins setValue:pin forKey:spot.message];
        }
        spot = [[TUIRouteController sharedInstance] nextSpot:YES];
    }
    [[TUIRouteController sharedInstance] reset];
}

- (void)dcMap:(DCMapView *)mv tapAtLatLon:(CLLocationCoordinate2D)coord {
	[super dcMap:mv tapAtLatLon:coord];
	
	[self closeActivePinInfoView];
}

- (void)dcMap:(DCMapView *)mv longPressAtLatLon:(CLLocationCoordinate2D)coord {
	[super dcMap:mv longPressAtLatLon:coord];
}

- (void)dcMap:(DCMapView *)mv zoomLevelChanged:(int)toZoomLevel canZoomIn:(BOOL)zoomIn canZoomOut:(BOOL)zoomOut {
	[super dcMap:mv zoomLevelChanged:toZoomLevel canZoomIn:zoomIn canZoomOut:zoomOut];
	
	_zoomStepper.value = toZoomLevel;
}

#pragma mark - DCMapPushPinDelegate methods
- (void)pushpinSelected:(DCMapPushpin *)pushpin
{
    NSString *message = [NSString stringWithFormat:@"Dropped pin at %f, %f", pushpin.coordinate.latitude, pushpin.coordinate.longitude];
    for (NSString *name in _droppedPins) {
        if (_droppedPins[name] == pushpin) {
            message = name;
            break;
        }
    }
	PinInfoView	*infoView = [[PinInfoView alloc] initWithPushpin:pushpin message:message delegate:self];
	
	[mapView insertSubview:infoView atIndex:0];
	
	[self closeActivePinInfoView];
	_activePinInfoView = infoView;
}

#pragma mark - PinInfoViewDelegate methods
-(void)pinInfoView:(PinInfoView *)piv pressedDiscloseButtonForPin:(DCMapPushpin *)pin
{
}

#pragma mark - DCNavigationDelegate methods
- (void)navigationManager:(DCNavigationManager *)manager update:(DCNavigationUpdate *)update {
	// Process the navigation update
	if (update.destinationReached) {
	}
	else if (update.guidance) {
        if (update.guidance.currentStreet) {
			_statusLabel.text = update.guidance.currentStreet;
		}
        if (update.guidance.nextStreet) {
			[self setNavigationActive:YES];
		}
		else {
			[self setNavigationActive:NO];
		}
        
        if (![update.guidance.maneuverIcon isEqualToIcon:_currentIcon] && mapView.isAnimating) {
			if (update.guidance.maneuverIcon)
			{
				NSArray		*images = [self generateImagesForManeuverIcon:update.guidance.maneuverIcon];
                
				// If we had configured icons to be dualLayered, there would be two images for the icon: one for the
				// inactive legs of the intersection, and one of the actual route being taken. Because we configured
				// the icons without this setting, though, they are combined into a single image.
				_nextManeuverCornerView.imgIcon.image = [images lastObject];
			}
			else
			{
				_nextManeuverCornerView.imgIcon.image = nil;
			}
			
			_currentIcon = update.guidance.maneuverIcon;
		}
		if (update.guidance.routePoints) {
			if (update.guidance.routePoints != _lastUpdate.guidance.routePoints) {
				[self setRoutePoints:update.guidance.routePoints completionHandler:nil];
			}
		}
		else {
			[self clearRoute];
		}
        _nextManeuverCornerView.lblText.attributedText = [FormatUtils formatDistance:_nextManeuverCornerView.lblText meters:update.guidance.distanceToCrossing imperial:NO];
        [self updateRemainingDisplay];
	}
	else if (_lastUpdate && _lastUpdate.guidance)
	{
		// Route has been cancelled
		[self setNavigationActive:NO];
		[self clearRoute];
	}
	
	[self updateVehiclePosition:update.vehiclePosition direction:update.vehicleDirection];
	_lastUpdate = update;
}

@end
