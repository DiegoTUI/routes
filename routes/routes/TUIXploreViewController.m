//
//  TUINavViewController.m
//  routes
//
//  Created by Diego Lafuente on 02/09/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIXploreViewController.h"
#import "TUIAppDelegate.h"

@interface TUIXploreViewController () <DCMapDelegate, DCNavigationDelegate, DCMapPushpinDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
// Navigation manager and updates
@property (strong, nonatomic) id navigationUpdateConnection;

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender;

@end

@implementation TUIXploreViewController

@synthesize lastUpdate;

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
    
    CLLocationCoordinate2D *buffer = malloc(sizeof(CLLocationCoordinate2D));
    CLLocationCoordinate2D routePoint;
    routePoint.latitude = 39.567741;
    routePoint.longitude = 2.647630;
    buffer[0] = routePoint;
    //NSData *pointsForNavigation = [self getRoutePointsForNavigation];
    //NSLog(@"pointsForNavigation length: %d", [pointsForNavigation length]);
    [self setRoutePoints:buffer count:sizeof(CLLocationCoordinate2D) completionHandler:nil];
    
    [self updateVehiclePosition:_guidanceConfig.origin direction:0];
	[self setNavigationCameraActive:YES];
	[self setDestination:_guidanceConfig.destination];
    
    self.navigationItem.title = @"Initializing...";
    
    _navigation.audioMuted = NO;
	_navigationActive = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    mapView.uiMargins = self.view.frame;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender {
    [_delegate closeButtonClicked];
}

#pragma mark - DCNavigationDelegate

- (void)navigationManager:(DCNavigationManager *)manager update:(DCNavigationUpdate *)update
{
	// Process the navigation update
	if (update.destinationReached)
	{
	}
	else if (update.guidance)
	{
		if (update.guidance.routePoints)
		{
			if (update.guidance.routePoints != lastUpdate.guidance.routePoints)
			{
				[self setRoutePoints:update.guidance.routePoints completionHandler:nil];
			}
		}
		else
		{
			[self clearRoute];
		}
	}
	else if (lastUpdate && lastUpdate.guidance)
	{
		// Route has been cancelled
		[self setNavigationActive:NO];
		[self clearRoute];
	}
	
	[self updateVehiclePosition:update.vehiclePosition direction:update.vehicleDirection];
	lastUpdate = update;
}

@end
