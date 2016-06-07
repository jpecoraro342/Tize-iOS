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
#import "GWTViewFactorySingleton.h"
#import "UIImage+Color.h"

@interface GWTEventsViewController () <UIBarPositioningDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* upcomingEvents;
@property (strong, nonatomic) NSMutableArray* myEvents;
@property (strong, nonatomic) NSMutableArray* myPastEvents;

@property (strong, nonatomic) NSMutableDictionary* attendingStatusMap;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) NSMutableArray *cellIsSelected;
@property (strong, nonatomic) NSIndexPath *indexPathForSwipingCell;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) NSInteger queryCompletionCount;

@end

@implementation GWTEventsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.cellIsSelected = [[NSMutableArray alloc] initWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
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
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    
    //UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"plus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(addEvent)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Contacts" style:UIBarButtonItemStyleBordered target:self action:@selector(viewFriends)];
    [self.toolbar setItems:[NSArray arrayWithObjects:addItem, flex, friends, nil]];
    [self.toolbar setBarTintColor:[UIColor lightGrayColor]];
    [self.toolbar setTintColor:kNavBarTintColor];
    
    [self.view addSubview:self.toolbar];
    
    UITableViewController *tableController = [[UITableViewController alloc] init];
    tableController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryData) forControlEvents:UIControlEventValueChanged];
    tableController.refreshControl = self.refreshControl;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //[self.tableView reloadRowsAtIndexPaths:@[self.indexPathForSwipingCell] withRowAnimation:UITableViewRowAnimationNone];

    //[self queryData];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    GWTEventCell *cell = (GWTEventCell*)[self.tableView cellForRowAtIndexPath:self.indexPathForSwipingCell];
    cell.shouldStayHighlighted = NO;
    [cell setHighlighted:NO animated:NO];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellIsSelected[indexPath.section][indexPath.row] boolValue]) {
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
    return 3;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSInteger headerViewHeight = [self tableView:self.tableView heightForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerViewHeight)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, headerViewHeight)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
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
    
    GWTEvent *tempEvent = [self eventForIndexPath:indexPath];
    
    cell.eventNameLabel.text = tempEvent.eventName;
    cell.eventTimeLabel.text = tempEvent.startTime;
    cell.eventLocationLabel.text = tempEvent.locationName;
    cell.eventHostLabel.text = tempEvent.hostName;
    cell.eventImageView.image = [self iconForIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cellIsSelected[indexPath.section][indexPath.row] = [NSNumber numberWithBool:![self.cellIsSelected[indexPath.section][indexPath.row] boolValue]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma TableView Helper Methods

-(GWTEvent *)eventForIndexPath:(NSIndexPath*)indexPath {
    if (([self.upcomingEvents count] + [self.myEvents count] + [self.myPastEvents count]) == 0) {
        return nil;
    }
    
    if (!indexPath) {
        return nil;
    }
    
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
    
    return tempEvent;
}

#pragma mark Query

-(void)queryData {
    self.queryCompletionCount = 0;
    
    [self queryEvents];
    [self queryAttendingStatus];
}

-(void)queryEvents {
    [self queryOtherEvents];
    [self queryMyEvents];
}

-(void)queryOtherEvents {
    //Get all the events we are invited to
    PFQuery *getEventUsers = [PFQuery queryWithClassName:@"EventUsers"];
    PFQuery *getAllEventsWeAreInvitedTo = [PFQuery queryWithClassName:@"Event"];
    PFQuery *getAllFollowing = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllPublicEventsFromFollowing = [PFQuery queryWithClassName:@"Event"];
    
    [getEventUsers whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [getAllEventsWeAreInvitedTo whereKey:@"objectId" matchesKey:@"eventID" inQuery:getEventUsers];
    [getAllEventsWeAreInvitedTo whereKey:@"endDate" greaterThanOrEqualTo:[NSDate date]];
    
    [getAllFollowing whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    
    [getAllPublicEventsFromFollowing whereKey:@"host" matchesKey:@"following" inQuery:getAllFollowing];
    [getAllPublicEventsFromFollowing whereKey:@"endDate" greaterThanOrEqualTo:[NSDate date]];
    [getAllPublicEventsFromFollowing whereKey:@"publicEvent" equalTo:[NSNumber numberWithBool:YES]];
    
    PFQuery *allQueries = [PFQuery orQueryWithSubqueries:@[getAllEventsWeAreInvitedTo, getAllPublicEventsFromFollowing]];
    [allQueries orderByAscending:@"startDate"];
    
    [allQueries findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self updateRefreshControl];
        if (!error) {
            self.upcomingEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            self.cellIsSelected[0] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (GWTEvent* event in objects) {
                [self.upcomingEvents addObject:event];
                [self.cellIsSelected[0] addObject:[NSNumber numberWithBool:NO]];
            }
            
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error loading other events: %@", error.localizedDescription);
            [[[UIAlertView alloc] initWithTitle:@"Unable to load events" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    }];
}

-(void)queryMyEvents {
    //get all of our own events
    PFQuery *getAllEventsForCurrentUser = [PFQuery queryWithClassName:@"Event"];
    [getAllEventsForCurrentUser includeKey:@"hostUser"];
    [getAllEventsForCurrentUser whereKey:@"host" equalTo:[PFUser currentUser].objectId];
    [getAllEventsForCurrentUser whereKey:@"endDate" greaterThanOrEqualTo:[[NSDate date] dateByAddingTimeInterval:-60*60*24*7]]; //Events where the endDate is more than 1 week ago
    [getAllEventsForCurrentUser orderByAscending:@"startDate"];
    [getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self updateRefreshControl];
            self.myEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            self.myPastEvents = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            self.cellIsSelected[1] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            self.cellIsSelected[2] = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (GWTEvent* event in objects) {
                if ([event.endDate compare:[NSDate new]] != NSOrderedAscending) {
                    [self.myEvents addObject:event];
                    [self.cellIsSelected[1] addObject:[NSNumber numberWithBool:NO]];
                }
                else {
                    [self.myPastEvents addObject:event];
                    [self.cellIsSelected[2] addObject:[NSNumber numberWithBool:NO]];
                }
            }
            
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error Querying My Events: %@", error.localizedDescription);
        }
    }];
}

-(void)queryAttendingStatus {
    //query my attending status
    PFQuery *attendingStatus = [PFQuery queryWithClassName:@"EventUsers"];
    [attendingStatus whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [attendingStatus findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error) {
        [self updateRefreshControl];
        if (!error) {
            self.attendingStatusMap = [[NSMutableDictionary alloc] init];
            for (PFObject *attendingStatus in objects) {
                [self.attendingStatusMap setObject:attendingStatus forKey:attendingStatus[@"eventID"]];
            }
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error Querying Attending Status: %@", error.localizedDescription);
        }
    }];
}

-(void)updateRefreshControl {
    static NSInteger numberOfQueries = 3;
    self.queryCompletionCount++;
    if (self.queryCompletionCount == numberOfQueries) {
        if (self.refreshControl && self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        self.queryCompletionCount = 0;
    }
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
    
    PFObject *attendingStatus = [self.attendingStatusMap objectForKey:event.objectId];
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
    GWTEditEventViewController *addEvent = [[GWTViewFactorySingleton viewManager] editEventViewController];
    addEvent.eventCreated = ^(GWTEvent *event) {
        [self createdEvent:event];
    };
    [self presentViewController:addEvent animated:YES completion:nil];
}

-(void)viewFriends {
    GWTContactsViewController *friends = [[GWTContactsViewController alloc] init];
    [self presentViewController:friends animated:YES completion:nil];
}

#pragma mark Navigation Methods

-(void)settings {
    GWTSettingsViewController *settingsPage = [[GWTViewFactorySingleton viewManager] settingsViewController];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsPage];
    [self presentViewController:settingsNavController animated:YES completion:nil];
}

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer *)gesture {
    self.indexPathForSwipingCell = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
    
    //Highlight the cell
    GWTEventCell *cell = (GWTEventCell*)[self.tableView cellForRowAtIndexPath:self.indexPathForSwipingCell];
    [cell setHighlighted:YES animated:NO];
    cell.shouldStayHighlighted = YES;
    
    return [self eventForIndexPath:self.indexPathForSwipingCell];
}

-(void)deleteEvent:(GWTEvent *)event {
    NSUInteger index = [self.myEvents indexOfObject:event];
    if (index != NSNotFound) {
        [self.myEvents removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }

    index = [self.myPastEvents indexOfObject:event];
    if (index != NSNotFound) {
        [self.myPastEvents removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)createdEvent:(GWTEvent *)event {
    NSUInteger index = [self.myEvents indexOfObject:event];
    if (index != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    index = [self.myPastEvents indexOfObject:event];
    if (index != NSNotFound) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    [self.myEvents insertObject:event atIndex:0];
    [[self.cellIsSelected objectAtIndex:1] insertObject:[NSNumber numberWithBool:NO] atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Main Events VC"];
}

@end
