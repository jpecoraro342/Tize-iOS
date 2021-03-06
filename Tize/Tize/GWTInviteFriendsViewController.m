//
//  GWTInviteFriendsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 9/28/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTSettingsViewController.h"
#import "GWTEventsViewController.h"
#import "UIImage+Color.h"
#import "GWTInviteFriendsViewController.h"
#import "GWTInviteFriendsToEventCommand.h"
#import "GWTContactsViewController.h"

@interface GWTInviteFriendsViewController () <UITabBarDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSMutableArray* listOfFriendsIveAdded;
@property (strong, nonatomic) NSMutableDictionary *friendsInvitedToEvent;

@property (nonatomic, strong) NSMutableArray* filteredListOfFriendsIveAdded;

@end

@implementation GWTInviteFriendsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self query];
        UITabBarItem *tize = self.tabBarItem;
        [tize setTitle:@"My Tize"];
        [tize setImage:[UIImage imageNamed:@"logo_tab_bar.png"]];
    }
    return self;
}

-(instancetype)initWithEvent:(GWTEvent *)event {
    self = [super init];
    if (self) {
        self.event = event;
        [self query];
        UITabBarItem *tize = self.tabBarItem;
        [tize setTitle:@"Invite Tize"];
        [tize setImage:[UIImage imageNamed:@"logo_tab_bar.png"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = cancel;
    
    UIBarButtonItem *invite = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
    self.rightBarButtonItem = invite;
    
    [self setSizeOfBottomBar:49];
}


#pragma mark - Tableview delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currentListOfFriends count];
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"Select Friends to Invite";
}

-(NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

-(NSString *)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row < [self.currentListOfFriends count]) {
        PFUser *friend = [self.currentListOfFriends objectAtIndex:indexPath.row];
        cell.textLabel.text = [friend username];
        cell.accessoryType = [self.friendsInvitedToEvent objectForKey:[friend objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUser *friend = [self.currentListOfFriends objectAtIndex:indexPath.row];
    if ([self.friendsInvitedToEvent objectForKey:[friend objectId]]) {
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

//NOTE: Modified to get everyone following us or us following them
-(void)querylistOfFriends {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    PFQuery *getAllFollowingMe = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersFollowingMe = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    
    [getAllFollowingMe whereKey:@"following" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersFollowingMe whereKey:@"objectId" matchesKey:@"user" inQuery:getAllFollowingMe];
    
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[getAllUsersFollowingMe, getAllUsersWeAreFollowing]];
    [both whereKey:@"userType" equalTo:@(0)];
    [both findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            self.listOfFriendsIveAdded = [[NSMutableArray alloc] init];
            for (PFUser *object in objects) {
                [self.listOfFriendsIveAdded addObject:object];
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
                    [self.friendsInvitedToEvent setObject:object forKey:[object objectId]];
                }
                [self.tableView reloadData];
            }
        }];
    }
    else {
        self.friendsInvitedToEvent = [[NSMutableDictionary alloc] init];
    }
}

-(void)updateInvitedListFromCommand {
    [self.friendsInvitedToEvent removeAllObjects];
    
    for (PFUser* friend in self.inviteCommand.friendsToInvite) {
        [self.friendsInvitedToEvent setObject:friend forKey:friend.objectId];
    }
    [self.tableView reloadData];
}

#pragma mark - Search

-(NSMutableArray*)currentListOfFriends {
    return [super searchIsActive] ? self.filteredListOfFriendsIveAdded : self.listOfFriendsIveAdded;
}

-(void)updateFilteredListsWithString:(NSString *)searchString {
    self.filteredListOfFriendsIveAdded = [self.listOfFriendsIveAdded mutableCopy];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@", searchString];
    if (searchString && ![searchString isEqualToString:@""]) {
        [self.filteredListOfFriendsIveAdded filterUsingPredicate:searchPredicate];
    }
}

#pragma mark - Other

-(void)addFriendAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFUser *user = [self.currentListOfFriends objectAtIndex:indexPath.row];
    [self.friendsInvitedToEvent setObject:user forKey:[user objectId]];
    
    [self.inviteCommand addFriend:user];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.currentListOfFriends objectAtIndex:indexPath.row];
    [self.friendsInvitedToEvent removeObjectForKey:[user objectId]];
    
    [self.inviteCommand removeFriend:user];
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteSelected {
    [((GWTContactsViewController*)self.tabBarController) inviteSelected];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Invite Friends to Event VC"];
}

@end
