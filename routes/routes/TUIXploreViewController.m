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

typedef enum RemainingDisplay {
	REMAINING_DISPLAY_TIME,
	REMAINING_DISPLAY_DISTANCE,
	REMAINING_DISPLAY_ARRIVAL,
	
	REMAINING_DISPLAY_COUNT
} RemainingDisplay;

#pragma mark - Private interface
@interface TUIXploreViewController () <DCMapDelegate, DCNavigationDelegate, DCMapPushpinDelegate, CornerViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
// Navigation manager and updates
@property (strong, nonatomic) id navigationUpdateConnection;
@property (strong, nonatomic) DCNavigationUpdate *lastUpdate;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *resetPositionBarButton;
@property (weak, nonatomic) IBOutlet NavigationCornerView *destinationCornerView;
@property (weak, nonatomic) IBOutlet NavigationCornerView *nextManeuverCornerView;
// Used for managing the UI
@property (nonatomic) BOOL navigationActive;
@property (strong,nonatomic) id<DCGuidanceIcon> currentIcon;
@property (nonatomic) NSInteger remainingDisplayType;

- (void)updateRemainingDisplay;
- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)resetPositionBarButtonClicked:(UIBarButtonItem *)sender;

@end

#pragma mark - Implementation
@implementation TUIXploreViewController

#pragma mark - Private methods
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
            display = [FormatUtils formatDistance:_destinationCornerView.lblText meters:_navigation.lastGuidance.distanceToDestination imperial:(_guidanceConfig.units == DCGuidanceUnitsImperial)];
            break;
            
        case REMAINING_DISPLAY_ARRIVAL:
            display = [FormatUtils formatArrivalTime:_destinationCornerView.lblText seconds:_navigation.lastGuidance.secondsToArrival];
            break;
	}
    
	_destinationCornerView.lblText.attributedText = display;
}

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender {
    [_navigation cancelGuidance];
    [self setNavigationActive:NO];
    [self clearRoute];
    [_delegate closeButtonClicked];
}

- (IBAction)resetPositionBarButtonClicked:(UIBarButtonItem *)sender {
    [self setNavigationCameraActive:YES];
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
	// Do any additional setup after loading the view.
    DCMapLaunchState *mapLaunchState = [[DCMapLaunchState alloc] init];
	DCNavLaunchState *navLaunchState = [[DCNavLaunchState alloc] initWithVehiclePositon:_guidanceConfig.origin direction:0];
    
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
    
    _navigation = [(TUIAppDelegate *)[[UIApplication sharedApplication] delegate] navigationManager];
	_navigationUpdateConnection = [_navigation registerForNavigationUpdatesWithDelegate:self];
    
    [self updateVehiclePosition:_guidanceConfig.origin direction:0];
	[self setNavigationCameraActive:YES];
	[self setDestination:_guidanceConfig.destination];
    
    _destinationCornerView.imgIcon.image = [UIImage imageNamed:@"geo_resources/flag_icon.png"];
    [_destinationCornerView setDelegate:self];
    
    _statusLabel.text = @"Initializing...";
    
    _navigation.audioMuted = NO;
	_navigationActive = NO;
    _remainingDisplayType = 0;
    
    /*CLLocationCoordinate2D *buffer = malloc(sizeof(CLLocationCoordinate2D));
    CLLocationCoordinate2D routePoint;
    routePoint.latitude = 39.567741;
    routePoint.longitude = 2.647630;
    buffer[0] = routePoint;
    //NSData *pointsForNavigation = [self getRoutePointsForNavigation];
    //NSLog(@"pointsForNavigation length: %d", [pointsForNavigation length]);
    [self setRoutePoints:buffer count:sizeof(CLLocationCoordinate2D) completionHandler:nil];*/
    
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
- (void)doneLoading:(DCMapView *)mv
{
	[super doneLoading:mv];
	
	const int	maneuverIconDim = _nextManeuverCornerView.imgIcon.frame.size.width;
	UIColor		*inactiveColor = [DCNavViewController maneuverIconDefaultInactiveColor];
	int			retinaFactor = [[UIScreen mainScreen] scale] - 1;
	
	[self configureManeuverIconsWithSize:(maneuverIconDim << retinaFactor) colorImages:NO dualLayered:NO inactiveColor:inactiveColor];
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
        _nextManeuverCornerView.lblText.attributedText = [FormatUtils formatDistance:_nextManeuverCornerView.lblText meters:update.guidance.distanceToCrossing imperial:(_guidanceConfig.units == DCGuidanceUnitsImperial)];
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
