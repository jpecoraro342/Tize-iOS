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

@interface GWTEventsViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* upcomingEvents;
@property (strong, nonatomic) NSMutableArray* myEvents;
@property (strong, nonatomic) NSMutableArray* promotionalEvents;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation GWTEventsViewController {
    NSMutableArray *_cellIsSelected;
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
    
    [self.navigationBar setBarTintColor:kNavBarColor];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    [self.navigationBar setItems:@[navItem]];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, self.view.frame.size.width, 44)];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Contacts" style:UIBarButtonItemStyleBordered target:self action:@selector(viewFriends)];
    [toolbar setItems:[NSArray arrayWithObjects:addItem, flex, friends, nil]];
    [toolbar setBarTintColor:[UIColor lightGrayColor]];
    [toolbar setTintColor:[UIColor darkGrayColor]];
    
    [self.view addSubview:toolbar];
}

-(void)viewWillAppear:(BOOL)animated {
    [self queryEvents];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cellIsSelected[indexPath.section][indexPath.row] boolValue]) {
        return 120;
    }
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
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
        case 2:
            titleLabel.text =  @"Promotions";
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
            return [self.promotionalEvents count];
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
        case 2: {
            tempEvent = [self.promotionalEvents objectAtIndex:indexPath.row];
            break;
        }
    }
    
    cell.eventNameLabel.text = tempEvent.eventName;
    cell.eventTimeLabel.text = tempEvent.startTime;
    cell.eventLocationLabel.text = tempEvent.locationName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _cellIsSelected[indexPath.section][indexPath.row] = [NSNumber numberWithBool:![_cellIsSelected[indexPath.section][indexPath.row] boolValue]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark Query

-(void)queryEvents {
    PFQuery *getEventUsers = [PFQuery queryWithClassName:@"EventUsers"];
    PFQuery *getAllEventsWeAreInvitedTo = [PFQuery queryWithClassName:@"Event"];
    
    [getEventUsers whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [getAllEventsWeAreInvitedTo whereKey:@"objectId" matchesKey:@"eventID" inQuery:getEventUsers];
    [getAllEventsWeAreInvitedTo findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _upcomingEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            _cellIsSelected[0] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (GWTEvent* event in objects) {
                [_upcomingEvents addObject:event];
                [_cellIsSelected[0] addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [self.tableView reloadData];
    }];
    
    PFQuery *getAllEventsForCurrentUser = [PFQuery queryWithClassName:@"Event"];
    [getAllEventsForCurrentUser whereKey:@"host" equalTo:[PFUser currentUser].objectId];
    [getAllEventsForCurrentUser orderByDescending:@"date"];
    [getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
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

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"\nTouches Began \nEvent: %@\n\n", [self getEventForTransitionFromGesture:[touches anyObject]]);
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

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer *)gesture {
    NSIndexPath *cellIndex = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
    switch (cellIndex.section) {
        case 0:
            return self.upcomingEvents[cellIndex.row];
        case 1:
            return self.myEvents[cellIndex.row];
        case 2:
            return self.promotionalEvents[cellIndex.row];
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
