//
//  TUIMasterViewController.m
//  routes
//
//  Created by Diego Lafuente on 26/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIMasterViewController.h"
#import "TUIRouteController.h"

#pragma mark - Private interface
@interface TUIMasterViewController () <TUIMapViewControllerDelegate>
@property (strong, nonatomic) NSArray *spots;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeBarButton;
@property (nonatomic) BOOL cellsDisabled;

-(IBAction)closeButtonClicked:(id)sender;
-(void)toggleBarButton:(bool)show;
-(void)TUIRouteFlushed:(NSNotification *)notification;
-(void)TUISpotRemoved:(NSNotification *)notification;
@end

#pragma mark - Implementation
@implementation TUIMasterViewController

#pragma mark - Private Methods
- (IBAction)closeButtonClicked:(id)sender {
    TUIMapViewController *mapViewController = (TUIMapViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [mapViewController closeMaster];
}

-(void)toggleBarButton:(bool)show {
    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    if (show) {
        if (![toolbarButtons containsObject:_closeBarButton]) {
            [toolbarButtons addObject:_closeBarButton];
            [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
        }
    } else {
        [toolbarButtons removeObject:_closeBarButton];
        [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
    }
}

-(void)TUIRouteFlushed:(NSNotification *)notification {
    _cellsDisabled = NO;
    [self.tableView reloadData];
}

-(void)TUISpotRemoved:(NSNotification *)notification {
    TUISpot *spot = notification.object;
    [self.tableView reloadRowsAtIndexPaths:@[spot.indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIViewController Methods
- (void)awakeFromNib {
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //load the icons
    NSString* spotsPath = [[NSBundle mainBundle] pathForResource:@"spots" ofType:@"plist"];
    _spots = [NSArray arrayWithContentsOfFile:spotsPath];
    TUIMapViewController *mapViewController = (TUIMapViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [mapViewController setDelegate:self];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self willRotateToInterfaceOrientation:orientation duration:0];
    _cellsDisabled = NO;
    //Suscribe to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(TUISpotRemoved:)
                                                 name:@"TUISpotRemoved"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(TUIRouteFlushed:)
                                                 name:@"TUIRouteFlushed"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //TODO: check here the orientation of the iPad and remove close button if needed
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIDeviceOrientationLandscapeRight) {
        [self toggleBarButton:NO];
        return;
    }
    [self toggleBarButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *spot = _spots[indexPath.row];
    cell.textLabel.text = spot[@"name"];
    if ([[TUIRouteController sharedInstance] spotForIndexPath:indexPath]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    //cell.selectionStyle = _cellsDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    cell.userInteractionEnabled = !_cellsDisabled;
    cell.textLabel.enabled = !_cellsDisabled;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
    if ([cell accessoryType] == UITableViewCellAccessoryNone) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSString *latstring = _spots[indexPath.row][@"latitude"];
        NSString *lonstring = _spots[indexPath.row][@"longitude"];
        TUISpot *spot = [[TUISpot alloc] initSpotOfType:TUIAttractionSpot latitude:[latstring doubleValue] longitude:[lonstring doubleValue] name:cell.textLabel.text];
        [spot setIndexPath:indexPath];
        [[TUIRouteController sharedInstance] addSpot:spot];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        TUISpot *spot = [[TUIRouteController sharedInstance] spotForIndexPath:indexPath];
        [[TUIRouteController sharedInstance] removeSpot:spot];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TUIMapViewControllerDelegate methods
/*-(void)aboutToRemoveSpot:(TUISpot *)spot {
    NSIndexPath *indexPath = nil;
    for (NSIndexPath *key in _spotMap) {
        if (_spotMap[key] == spot) {
            indexPath = key;
        }
    }
    if (indexPath) {    //we found something to uncheck
        [_spotMap removeObjectForKey:indexPath];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)aboutToRemoveAllSpots {
    _spotMap = [NSMutableDictionary dictionary];
    _cellsDisabled = NO;
    [self.tableView reloadData];
}*/

-(void)disableCells:(BOOL)cellsDisabled {
    _cellsDisabled = cellsDisabled;
    [self.tableView reloadData];
}


@end
