//
//  GWTEventsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTEventsViewController.h"
#import "GWTEventCell.h"
#import "GWTEvent.h"
#import "GWTEventDetailViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTFriendsTableViewController.h"
#import "GWTAttendingTableViewController.h"
#import "GWTBasePageViewController.h"
#import "GWTSettingsViewController.h"

@interface GWTEventsViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* upcomingEvents;
@property (strong, nonatomic) NSMutableArray* myEvents;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation GWTEventsViewController {
    NSMutableArray *_cellIsSelected;
    NSIndexPath *_indexPathForSwipingCell;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _cellIsSelected = [[NSMutableArray alloc] initWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
        [self queryEvents];
    }
    return self;
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *eventCell = [UINib nibWithNibName:@"GWTEventCell" bundle:nil];
    [self.tableView registerNib:eventCell forCellReuseIdentifier:@"eventCell"];
    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"settings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.rightBarButtonItem = settings;
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setTintColor:kNavBarTintColor];
    [self.navigationBar setBarTintColor:kNavBarColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, self.view.frame.size.width, 44)];
    
    //UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"plus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(addEvent)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Contacts" style:UIBarButtonItemStyleBordered target:self action:@selector(viewFriends)];
    [toolbar setItems:[NSArray arrayWithObjects:addItem, flex, friends, nil]];
    [toolbar setBarTintColor:[UIColor lightGrayColor]];
    [toolbar setTintColor:kNavBarTintColor];
    
    [self.view addSubview:toolbar];
    
    UITableViewController *tableController = [[UITableViewController alloc] init];
    tableController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryEvents) forControlEvents:UIControlEventValueChanged];
    tableController.refreshControl = self.refreshControl;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryEvents];
}

-(void)viewDidDisappear:(BOOL)animated {
    GWTEventCell *cell = (GWTEventCell*)[self.tableView cellForRowAtIndexPath:_indexPathForSwipingCell];
    cell.shouldStayHighlighted = NO;
    [cell setHighlighted:NO animated:NO];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cellIsSelected[indexPath.section][indexPath.row] boolValue]) {
        return 120;
    }
    return 66;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    switch (section) {
        case 0:
            titleLabel.text = @"Upcoming Events";
            break;
        case 1:
            titleLabel.text = @"My Events";
            break;
    }
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.upcomingEvents count];
        case 1:
            return [self.myEvents count];
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GWTEventCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    GWTEvent *tempEvent;
    switch (indexPath.section) {
        case 0: {
            tempEvent = [self.upcomingEvents objectAtIndex:indexPath.row];
            break;
        }
        case 1: {
            tempEvent = [self.myEvents objectAtIndex:indexPath.row];
            break;
        }
    }
    
    cell.eventNameLabel.text = tempEvent.eventName;
    cell.eventTimeLabel.text = tempEvent.startTime;
    cell.eventLocationLabel.text = tempEvent.locationName;
    cell.eventHostLabel.text = tempEvent.hostUser.username;
    cell.eventImageView.image = [UIImage imageNamed:tempEvent.icon];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _cellIsSelected[indexPath.section][indexPath.row] = [NSNumber numberWithBool:![_cellIsSelected[indexPath.section][indexPath.row] boolValue]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark Query

-(void)queryEvents {
    //Get all the events we are invited to
    PFQuery *getEventUsers = [PFQuery queryWithClassName:@"EventUsers"];
    PFQuery *getAllEventsWeAreInvitedTo = [PFQuery queryWithClassName:@"Event"];
    [getAllEventsWeAreInvitedTo includeKey:@"hostUser"];
    
    [getEventUsers whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [getAllEventsWeAreInvitedTo whereKey:@"objectId" matchesKey:@"eventID" inQuery:getEventUsers];
    [getAllEventsWeAreInvitedTo whereKey:@"endDate" greaterThanOrEqualTo:[NSDate date]];
    [getAllEventsWeAreInvitedTo orderByAscending:@"startDate"];
    [getAllEventsWeAreInvitedTo findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.refreshControl && self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            _upcomingEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            _cellIsSelected[0] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (GWTEvent* event in objects) {
                [_upcomingEvents addObject:event];
                [_cellIsSelected[0] addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [self.tableView reloadData];
    }];

    //get all of our own events
    PFQuery *getAllEventsForCurrentUser = [PFQuery queryWithClassName:@"Event"];
    [getAllEventsForCurrentUser includeKey:@"hostUser"];
    [getAllEventsForCurrentUser whereKey:@"host" equalTo:[PFUser currentUser].objectId];
    [getAllEventsForCurrentUser orderByAscending:@"startDate"];
    [getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.refreshControl && self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            _myEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            _cellIsSelected[1] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (GWTEvent* event in objects) {
                [_myEvents addObject:event];
                [_cellIsSelected[1] addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [self.tableView reloadData];
    }];
}

#pragma mark User Management

-(void)addEvent {
    GWTEditEventViewController *addEvent = [[GWTEditEventViewController alloc] init];
    [self presentViewController:addEvent animated:YES completion:nil];
}

-(void)viewFriends {
    GWTFriendsTableViewController *friends = [[GWTFriendsTableViewController alloc] init];
    [self presentViewController:friends animated:YES completion:nil];
}

#pragma mark Navigation Methods

-(void)settings {
    GWTSettingsViewController *settingsPage = [[GWTSettingsViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsPage];
    [self presentViewController:settingsNavController animated:YES completion:nil];
}

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer *)gesture {
    _indexPathForSwipingCell = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
    GWTEventCell *cell = (GWTEventCell*)[self.tableView cellForRowAtIndexPath:_indexPathForSwipingCell];
    [cell setHighlighted:YES animated:YES];
    cell.shouldStayHighlighted = YES;
    NSLog(@"Highlighting Cell");
    
    switch (_indexPathForSwipingCell.section) {
        case 0:
            if (_indexPathForSwipingCell.row < [self.upcomingEvents count]) {
                return self.upcomingEvents[_indexPathForSwipingCell.row];
            }
        case 1:
            if (_indexPathForSwipingCell.row < [self.myEvents count]) {
                return self.myEvents[_indexPathForSwipingCell.row];
            }
    }
    return nil;
}

-(void)deleteEvent:(GWTEvent *)event {
    [self.myEvents removeObject:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Main Events VC"];
}

@end
