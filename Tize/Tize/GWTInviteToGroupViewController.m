//
//  GWTInviteToGroupViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/8/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTInviteToGroupViewController.h"
#import "GWTAddToGroupCommand.h"
#import <Parse/Parse.h>

@interface GWTInviteToGroupViewController ()

@property (strong, nonatomic) NSMutableArray *listOfFriends;
@property (nonatomic, strong) NSMutableArray *listOfFriendsInGroup;
@property (strong, nonatomic) NSMutableDictionary *friendsInGroup;

@property (nonatomic, strong) PFObject *group;

@end

@implementation GWTInviteToGroupViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.friendsInGroup = [[NSMutableDictionary alloc] init];
        [self query];
    }
    return self;
}

-(instancetype)initWithGroup:(PFObject *)group {
    self = [super init];
    if (self) {
        self.group = group;
        self.friendsInGroup = [[NSMutableDictionary alloc] init];
        self.inviteFriendsCommand = [[GWTAddToGroupCommand alloc] initWithGroupID:group.objectId];
        [self query];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    UIBarButtonItem *invite = [[UIBarButtonItem alloc] initWithTitle:@"Add New" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
    
    self.leftBarButtonItem = cancel;
    self.rightBarButtonItem = invite;
}

#pragma mark - Tableview


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.listOfFriendsInGroup count];
        case 1:
            return [self.listOfFriends count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.group[@"name"];
        case 1:
            return @"Invite to Group";
    }
    
    return @"";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self.listOfFriendsInGroup[indexPath.row] username];
        case 1:
            return [self.listOfFriends[indexPath.row] username];
    }
    return @"";
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    switch (indexPath.section) {
        case 0: {
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1: {
            if (indexPath.row < [self.listOfFriends count]) {
                PFUser *friend = [self.listOfFriends objectAtIndex:indexPath.row];
                cell.accessoryType = [self.friendsInGroup objectForKey:[friend objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        PFUser *friend = [self.listOfFriends objectAtIndex:indexPath.row];
        if ([self.friendsInGroup objectForKey:[friend objectId]]) {
            [self removeFriendAtIndexPath:indexPath];
        }
        else {
            [self addFriendAtIndexPath:indexPath];
        }
    }
}

#pragma mark query

-(void)query {
    [self querylistOfFriends];
    [self queryInGroup];
}

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
            self.listOfFriends = [[NSMutableArray alloc] init];
            for (PFUser *object in objects) {
                [self.listOfFriends addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

-(void)queryInGroup {
    PFQuery *groupUsers = [PFQuery queryWithClassName:@"GroupUsers"];
    [groupUsers whereKey:@"group" equalTo:[PFObject objectWithoutDataWithClassName:@"Groups" objectId:self.group.objectId]];
    [groupUsers includeKey:@"user"];
    [groupUsers findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            self.listOfFriendsInGroup = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (PFUser *object in objects) {
                PFUser *user = object[@"user"];
                [self.friendsInGroup setObject:user forKey:[user objectId]];
            }
            //To handle duplicates -- ughh!
            [self.friendsInGroup enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self.listOfFriendsInGroup addObject:obj];
            }];
            
            [self.tableView reloadData];
        }
    }];
    
}

#pragma mark Other

-(void)addFriendAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFUser *user = [self.listOfFriends objectAtIndex:indexPath.row];
    [self.friendsInGroup setObject:user forKey:[user objectId]];
    
    //[self.listOfFriendsInGroup addObject:user];
    //[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.listOfFriendsInGroup count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.listOfFriends objectAtIndex:indexPath.row];
    [self.friendsInGroup removeObjectForKey:[user objectId]];
    
    //[self.listOfFriendsInGroup removeObject:user];
    //[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.listOfFriendsInGroup count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    
    //TODO:Write the code to remove a friend from the group
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteSelected {
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    
    [self.friendsInGroup enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [invited addObject:obj];
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.inviteFriendsCommand.listOfFriends = invited;
        [self.inviteFriendsCommand execute];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Invite Friends to Event VC"];
}

@end
