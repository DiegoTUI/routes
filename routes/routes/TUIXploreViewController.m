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

@end
