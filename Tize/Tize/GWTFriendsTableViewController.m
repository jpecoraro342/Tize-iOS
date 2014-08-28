//
//  GWTFriendsTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTFriendsTableViewController.h"
#import "GWTEventsViewController.h"

@interface GWTFriendsTableViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation GWTFriendsTableViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        _listOfFriends = [[NSMutableArray alloc] init];
        [self queryFollowing];
    }
    return self;
}

-(instancetype)initWithEvent:(GWTEvent *)event {
    self = [super init];
    if (self) {
        self.isInviteList = YES;
        self.event = event;
        _listOfFriends = [[NSMutableArray alloc] init];
        [self queryFollowing];
    }
    return self;
}

-(void)reloadWithEvent:(GWTEvent *)event {
    self.isInviteList = YES;
    self.event = event;
    [self queryFollowing];
    
    self.tableView.allowsMultipleSelection = YES;
    /*
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, self.view.frame.size.width, 44)];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
    [toolbar setItems:[NSArray arrayWithObjects:friends, flex, cancel, nil]];*/
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    /*
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44, self.view.frame.size.width, 44)];
    
    if (self.isInviteList) {
        self.tableView.allowsMultipleSelection = YES;
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *friends = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
        [toolbar setItems:[NSArray arrayWithObjects:friends, flex, cancel, nil]];
    }
    else {
        [toolbar setItems:@[cancel]];
    }*/
    
    [self.navigationBar setBarTintColor:kNavBarColor];
    [self.navigationBar setTintColor:[UIColor darkGrayColor]];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.leftBarButtonItem = cancel;
    [self.navigationBar setItems:@[navItem]];
    
    //[self.view addSubview:toolbar];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

-(void)inviteSelected {
    if (!self.event)
        return;
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *eventUserObjects = [[NSMutableArray alloc] init];
    for (int i = 0; i < [selectedRows count]; i++) {
        PFObject *invite = [PFObject objectWithClassName:@"EventUsers"];
        invite[@"userID"] = [[self.listOfFriends objectAtIndex:[[selectedRows objectAtIndex:i] row]] objectId];
        invite[@"attendingStatus"] = [NSNumber numberWithInt:3];
        invite[@"eventID"] = self.event.objectId;
        [eventUserObjects addObject:invite];
    }
    NSLog(@"\nInviting %d friends to \nEvent: %@\n\n", [eventUserObjects count], self.event.eventName);
     [PFObject saveAllInBackground:eventUserObjects block:^(BOOL succeeded, NSError *error) {
         if (succeeded) {
             NSLog(@"\nFriends successfully invited!\n\n");
         }
         else {
             NSLog(@"\nError: %@", error.localizedDescription);
         }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableview delegate methods

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
        case 0: {
            titleLabel.text = @"Friends";
            break;
        }
        case 1:
            titleLabel.text = @"Groups";
            break;
        case 2:
            titleLabel.text =  @"Organizations";
            break;
    }
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.listOfFriends count];
        case 1:
            return 0; //return the number of groups in the group list
        case 2:
            return 0; //return the number of organizations in your organization list
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (indexPath.row < [self.listOfFriends count]) {
            cell.textLabel.text = [[self.listOfFriends objectAtIndex:indexPath.row] username];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark query

-(void)queryFollowing {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFUser *object in objects) {
                [self.listOfFriends addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
