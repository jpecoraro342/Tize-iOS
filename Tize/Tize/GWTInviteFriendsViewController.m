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

@interface GWTInviteFriendsViewController () <UITabBarDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSMutableArray* listOfFriendsIveAdded;
@property (strong, nonatomic) NSMutableDictionary *friendsInvitedToEvent;

@end

@implementation GWTInviteFriendsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self query];
        UITabBarItem *tize = self.tabBarItem;
        [tize setTitle:@"Invite Tize"];
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
    return [self.listOfFriendsIveAdded count];
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
    
    if (indexPath.row < [self.listOfFriendsIveAdded count]) {
        PFUser *friend = [self.listOfFriendsIveAdded objectAtIndex:indexPath.row];
        cell.textLabel.text = [friend username];
        cell.accessoryType = [self.friendsInvitedToEvent objectForKey:[friend objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUser *friend = [self.listOfFriendsIveAdded objectAtIndex:indexPath.row];
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

-(void)querylistOfFriends {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
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
}

#pragma mark Other

-(void)addFriendAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFUser *user = [self.listOfFriendsIveAdded objectAtIndex:indexPath.row];
    [self.friendsInvitedToEvent setObject:user forKey:[user objectId]];
    
    [self.inviteCommand addFriend:user];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.listOfFriendsIveAdded objectAtIndex:indexPath.row];
    [self.friendsInvitedToEvent removeObjectForKey:[user objectId]];
    
    [self.inviteCommand removeFriend:user];
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteSelected {
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    
    //execute the command and/or tell them dont be lazy
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Invite Friends to Event VC"];
}

@end
