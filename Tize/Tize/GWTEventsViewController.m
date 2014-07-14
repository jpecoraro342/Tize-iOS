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

@interface GWTEventsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* eventsArray;

@end

@implementation GWTEventsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self queryEvents];
    }
    return self;
}

#pragma mark loading view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *eventCell = [UINib nibWithNibName:@"GWTEventCell" bundle:nil];
    [self.tableView registerNib:eventCell forCellReuseIdentifier:@"eventCell"];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, self.view.frame.size.width, 44)];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Contacts" style:UIBarButtonItemStyleBordered target:self action:@selector(viewFriends)];
    [toolbar setItems:[NSArray arrayWithObjects:addItem, flex, friends, nil]];
    
    [self.view addSubview:toolbar];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blueBackground.png"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [self queryEvents];
}

#pragma mark tableview delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GWTEventCell* cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    if (indexPath.row < [self.eventsArray count]) {
        GWTEvent* tempEvent = [self.eventsArray objectAtIndex:indexPath.row];
        cell.eventNameLabel.text = tempEvent.eventName;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark query methods

-(void)queryEvents {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllEventsForUsersWeAreFollowing = [PFQuery queryWithClassName:@"Event"];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllEventsForUsersWeAreFollowing whereKey:@"host" matchesKey:@"following" inQuery:getAllFollowingEvents];
    /*[getAllEventsForUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFObject *object in objects) {
                [self.eventsArray addObject:object];
            }
            [self.tableView reloadData];
        }
    }];*/
    
    PFQuery *getAllEventsForCurrentUser = [PFQuery queryWithClassName:@"Event"];
    [getAllEventsForCurrentUser whereKey:@"host" equalTo:[PFUser currentUser].objectId];
    /*[getAllEventsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [self.eventsArray addObject:object];
            }
        }
        [self.tableView reloadData];
    }];*/
    
    PFQuery *eventsQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:getAllEventsForCurrentUser, getAllEventsForUsersWeAreFollowing, nil]];
    [eventsQuery orderByDescending:@"date"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _eventsArray = [[NSMutableArray alloc] init];
            for (PFObject *object in objects) {
                [self.eventsArray addObject:object];
            }
        }
        [self.tableView reloadData];
    }];
}

#pragma mark user management

-(void)addEvent {
    GWTEditEventViewController *addEvent = [[GWTEditEventViewController alloc] init];
    [self presentViewController:addEvent animated:YES completion:nil];
}

-(void)viewFriends {
    GWTFriendsTableViewController *friends = [[GWTFriendsTableViewController alloc] init];
    [self presentViewController:friends animated:YES completion:nil];
}

#pragma mark navigation methods

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer *)gesture {
    NSIndexPath *cellIndex = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
    NSLog(@"Transitioning, set the selected event to %@\n\n", [self.eventsArray objectAtIndex:cellIndex.row]);
    return [self.eventsArray objectAtIndex:cellIndex.row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
