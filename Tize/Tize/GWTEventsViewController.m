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
#import "GWTContactsViewController.h"
#import "GWTAttendingTableViewController.h"
#import "GWTBasePageViewController.h"
#import "GWTSettingsViewController.h"
#import "UIImage+Color.h"

@interface GWTEventsViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* upcomingEvents;
@property (strong, nonatomic) NSMutableArray* myEvents;
@property (strong, nonatomic) NSMutableArray* myPastEvents;

@property (strong, nonatomic) NSMutableDictionary* attendingStatusMap;

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
        [self queryData];
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
    [self.refreshControl addTarget:self action:@selector(queryData) forControlEvents:UIControlEventValueChanged];
    tableController.refreshControl = self.refreshControl;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //[self.tableView reloadRowsAtIndexPaths:@[_indexPathForSwipingCell] withRowAnimation:UITableViewRowAnimationNone];

    //[self queryData];
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
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 40)];
    [titleLabel setFont:[UIFont systemFontOfSize:20]];
    [titleLabel setTextColor:kWhiteColor];
    
    switch (section) {
        case 0:
            titleLabel.text = @"Upcoming Events";
            break;
        case 1:
            titleLabel.text = @"My Events";
            break;
        case 2:
            titleLabel.text = @"My Past Events";
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
        case 2:
            return [self.myPastEvents count];
    }
    return 0;
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
        case 2: {
            tempEvent = [self.myPastEvents objectAtIndex:indexPath.row];
            break;
        }
    }
    
    cell.eventNameLabel.text = tempEvent.eventName;
    cell.eventTimeLabel.text = tempEvent.startTime;
    cell.eventLocationLabel.text = tempEvent.locationName;
    cell.eventHostLabel.text = tempEvent.hostUser.username;
    cell.eventImageView.image = [self iconForIndexPath:indexPath];
    
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

-(void)queryData {
    [self queryEvents];
    [self queryAttendingStatus];
}

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
    [getAllEventsForCurrentUser whereKey:@"endDate" greaterThanOrEqualTo:[[NSDate date] dateByAddingTimeInterval:-60*60*24*7]]; //Events where the endDate is more than 1 week ago
    [getAllEventsForCurrentUser orderByAscending:@"startDate"];
    [getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.refreshControl && self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            _myEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            _myPastEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            _cellIsSelected[1] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            _cellIsSelected[2] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (GWTEvent* event in objects) {
                if ([event.endDate compare:[NSDate new]] != NSOrderedAscending) {
                    [_myEvents addObject:event];
                    [_cellIsSelected[1] addObject:[NSNumber numberWithBool:NO]];
                }
                else {
                    [_myPastEvents addObject:event];
                    [_cellIsSelected[2] addObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
        [self.tableView reloadData];
    }];
}

-(void)queryAttendingStatus {
    //query my attending status
    PFQuery *attendingStatus = [PFQuery queryWithClassName:@"EventUsers"];
    [attendingStatus whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [attendingStatus findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error) {
        if (!error) {
            _attendingStatusMap = [[NSMutableDictionary alloc] init];
            for (PFObject *attendingStatus in objects) {
                [_attendingStatusMap setObject:attendingStatus forKey:attendingStatus[@"eventID"]];
            }
            [self.tableView reloadData];
        }
        else {

        }
    }];
}

#pragma mark User Management

-(UIImage*)iconForIndexPath:(NSIndexPath*)indexPath {
    GWTEvent *event;
    switch (indexPath.section) {
        case 0: {
            event = [self.upcomingEvents objectAtIndex:indexPath.row];
            break;
        }
        case 1: {
            event = [self.myEvents objectAtIndex:indexPath.row];
            break;
        }
        case 2: {
            event = [self.myPastEvents objectAtIndex:indexPath.row];
            break;
        }
            
    }
    
    if (indexPath.section > 0) {
        return [UIImage imageNamed:event.icon];
    }
    
    PFObject *attendingStatus = [_attendingStatusMap objectForKey:event.objectId];
    if (attendingStatus) {
        NSInteger status = [attendingStatus[@"attendingStatus"] integerValue];
        switch (status) {
            case 0: {
                return [UIImage imageNamed:event.icon];
            }
                break;
            case 1: {
                return [UIImage imageNamed:event.icon withColor:kLightOrangeColor];
            }
                break;
            case 2: {
                return [UIImage imageNamed:event.icon withColor:kRedColor];
            }
                break;
            case 3: {
                return [UIImage imageNamed:event.icon withColor:[UIColor lightGrayColor]];
            }
                break;
                
            default:
                break;
        }
    }
    
    return [UIImage imageNamed:event.icon];
}

-(void)addEvent {
    GWTEditEventViewController *addEvent = [[GWTEditEventViewController alloc] init];
    [self presentViewController:addEvent animated:YES completion:nil];
}

-(void)viewFriends {
    GWTContactsViewController *friends = [[GWTContactsViewController alloc] init];
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
    
    //Highlight the cell
    GWTEventCell *cell = (GWTEventCell*)[self.tableView cellForRowAtIndexPath:_indexPathForSwipingCell];
    [cell setHighlighted:YES animated:NO];
    cell.shouldStayHighlighted = YES;
    
    switch (_indexPathForSwipingCell.section) {
        case 0:
            if (_indexPathForSwipingCell.row < [self.upcomingEvents count]) {
                return self.upcomingEvents[_indexPathForSwipingCell.row];
            }
        case 1:
            if (_indexPathForSwipingCell.row < [self.myEvents count]) {
                return self.myEvents[_indexPathForSwipingCell.row];
            }
        case 2:
            if (_indexPathForSwipingCell.row < [self.myPastEvents count]) {
                return self.myPastEvents[_indexPathForSwipingCell.row];
            }
    }
    return nil;
}

-(void)deleteEvent:(GWTEvent *)event {
    [self.myEvents removeObject:event];
    [self.myPastEvents removeObject:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Main Events VC"];
}

@end
