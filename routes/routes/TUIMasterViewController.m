//
//  TUIMasterViewController.m
//  routes
//
//  Created by Diego Lafuente on 26/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIMasterViewController.h"

#import "TUIDetailViewController.h"

#pragma mark - Private interface
@interface TUIMasterViewController ()
@property (strong, nonatomic) NSArray *spots;
@property (strong, nonatomic) NSMutableDictionary *pinMap;

-(IBAction)closeButtonClicked:(id)sender;
@end

#pragma mark - Implementation
@implementation TUIMasterViewController

#pragma mark - Private Methods
- (IBAction)closeButtonClicked:(id)sender {
    [_mapViewController closeMaster];
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
    _pinMap = [NSMutableDictionary dictionary];
    self.mapViewController = (TUIMapViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //TODO: check here the orientetion of the iPad and remove close button if needed
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
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
    if ([cell accessoryType] == UITableViewCellAccessoryNone) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSString *latstring = _spots[indexPath.row][@"latitude"];
        NSString *lonstring = _spots[indexPath.row][@"longitude"];
        deCartaPin *pin = [_mapViewController addPinAtLatitude:[latstring doubleValue] andLongitude:[lonstring doubleValue]];
        //register pin
        [_pinMap setObject:pin forKey:indexPath];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [_mapViewController removePin:[_pinMap objectForKey:indexPath]];
        [_pinMap removeObjectForKey:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
