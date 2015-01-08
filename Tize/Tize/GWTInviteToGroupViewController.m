//
//  GWTInviteToGroupViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/8/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTInviteToGroupViewController.h"
#import <Parse/Parse.h>

@interface GWTInviteToGroupViewController ()

@property (strong, nonatomic) NSMutableArray *listOfFriends;
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
        [self query];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    UIBarButtonItem *invite = [[UIBarButtonItem alloc] initWithTitle:@"Add to Group" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
    
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
            return [self.listOfFriends count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return self.group[@"name"];
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return [self.listOfFriends[indexPath.row] username];
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return @"";
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"subtitlecell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitlecell"];
    }
    
    if (indexPath.row < [self.listOfFriends count]) {
        PFUser *friend = [self.listOfFriends objectAtIndex:indexPath.row];
        cell.textLabel.text = [friend username];
        cell.accessoryType = [self.friendsInGroup objectForKey:[friend objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUser *friend = [self.listOfFriends objectAtIndex:indexPath.row];
    if ([self.friendsInGroup objectForKey:[friend objectId]]) {
        [self removeFriendAtIndexPath:indexPath];
    }
    else {
        [self addFriendAtIndexPath:indexPath];
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

-(void)queryInGroup {
    PFQuery *eventUsers = [PFQuery queryWithClassName:@"GroupUsers"];
    [eventUsers whereKey:@"group" equalTo:self.group];
    PFQuery *getAllUsersInvited = [PFUser query];
    [getAllUsersInvited whereKey:@"objectId" matchesKey:@"userID" inQuery:eventUsers];
    [getAllUsersInvited findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFUser *object in objects) {
                [self.friendsInGroup setObject:object forKey:[object objectId]];
            }
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
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.listOfFriends objectAtIndex:indexPath.row];
    [self.friendsInGroup removeObjectForKey:[user objectId]];
    //TODO:Write the code to remove a friend
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
