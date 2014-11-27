//
//  GWTInviteFriendsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 9/28/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTAddFriendViewController.h"
#import "GWTSettingsViewController.h"
#import "GWTEventsViewController.h"
#import "UIImage+Color.h"
#import "GWTInviteFriendsViewController.h"

@interface GWTInviteFriendsViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *listOfFriends;
@property (strong, nonatomic) NSMutableDictionary *listOfInvited;

@end

@implementation GWTInviteFriendsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.listOfInvited = [[NSMutableDictionary alloc] init];
        [self query];
    }
    return self;
}

-(instancetype)initWithEvent:(GWTEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
        self.listOfInvited = [[NSMutableDictionary alloc] init];
        [self query];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    
    UIBarButtonItem *invite = [[UIBarButtonItem alloc] initWithTitle:@"Invite Selected" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.rightBarButtonItem = invite;
    navItem.leftBarButtonItem = cancel;
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setTintColor:kNavBarTintColor];
    [self.navigationBar setBarTintColor:kNavBarColor];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark tableview delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    titleLabel.text = @"Select Friends To Invite";
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfFriends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    if (indexPath.row < [self.listOfFriends count]) {
        PFUser *friend = [self.listOfFriends objectAtIndex:indexPath.row];
        cell.textLabel.text = [friend username];
        cell.accessoryType = [self.listOfInvited objectForKey:[friend objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUser *friend = [self.listOfFriends objectAtIndex:indexPath.row];
    if ([self.listOfInvited objectForKey:[friend objectId]]) {
        [self removeFriendAtIndexPath:indexPath];
    }
    else {
        [self addFriendAtIndexPath:indexPath];
    }
}

#pragma mark query

-(void)query {
    [self querylistOfFriends];
    [self queryInvited];
}

-(void)querylistOfFriends {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            self.listOfFriends = [[NSMutableArray alloc] init];
            for (PFUser *object in objects) {
                [self.listOfFriends addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

-(void)queryInvited {
    if (self.event.objectId) {
        PFQuery *eventUsers = [PFQuery queryWithClassName:@"EventUsers"];
        [eventUsers whereKey:@"eventID" equalTo:self.event.objectId];
        PFQuery *getAllUsersInvited = [PFUser query];
        [getAllUsersInvited whereKey:@"objectId" matchesKey:@"userID" inQuery:eventUsers];
        [getAllUsersInvited findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
            if(!error) {
                for (PFUser *object in objects) {
                    [self.listOfInvited setObject:object forKey:[object objectId]];
                }
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark Other

-(void)addFriendAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFUser *user = [self.listOfFriends objectAtIndex:indexPath.row];
    [self.listOfInvited setObject:user forKey:[user objectId]];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.listOfFriends objectAtIndex:indexPath.row];
    [self.listOfInvited removeObjectForKey:[user objectId]];
    //TODO:Write the code to remove a friend
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteSelected {
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    
    [self.listOfInvited enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [invited addObject:obj];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock(invited);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Invite Friends to Event VC"];
}

@end
