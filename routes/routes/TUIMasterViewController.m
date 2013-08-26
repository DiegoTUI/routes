//
//  TUIMasterViewController.m
//  routes
//
//  Created by Diego Lafuente on 26/08/13.
//  Copyright (c) 2013 Tui Travel A&D. All rights reserved.
//

#import "TUIMasterViewController.h"

#import "TUIDetailViewController.h"

@interface TUIMasterViewController ()
@property (strong, nonatomic) NSArray *spots;

-(IBAction)closeButtonClicked:(id)sender;
@end

@implementation TUIMasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //load the icons
    NSString* spotsPath = [[NSBundle mainBundle] pathForResource:@"spots" ofType:@"plist"];
    _spots = [NSArray arrayWithContentsOfFile:spotsPath];
    self.mapViewController = (TUIMapViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *spot = _spots[indexPath.row];
    cell.textLabel.text = spot[@"name"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
    if ([cell accessoryType] == UITableViewCellAccessoryNone) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)closeButtonClicked:(id)sender {
    [_mapViewController closeMaster];
}
@end
