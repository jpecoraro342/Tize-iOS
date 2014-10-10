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
@property (strong, nonatomic) NSMutableArray *listOfInvited;

@property (strong, nonatomic) NSMutableArray *isSelected;

@end

@implementation GWTInviteFriendsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        _listOfFriends = [[NSMutableArray alloc] init];
        [self querylistOfFriends];
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
    
    cell.textLabel.text = [[self.listOfFriends objectAtIndex:indexPath.row] username];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([self.isSelected[indexPath.row] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.isSelected[indexPath.row] = [NSNumber numberWithBool:NO];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.isSelected[indexPath.row] = [NSNumber numberWithBool:YES];
    }
}

#pragma mark query

-(void)querylistOfFriends {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            self.listOfFriends = [[NSMutableArray alloc] init];
            self.isSelected = [[NSMutableArray alloc] init];
            for (PFUser *object in objects) {
                [self.listOfFriends addObject:object];
                [self.isSelected addObject:[NSNumber numberWithBool:NO]];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark Other

-(void)addFriendAtIndex:(NSInteger)index {
    PFObject *following = [PFObject objectWithClassName:@"Following"];
    following[@"user"] = [[PFUser currentUser] objectId];
    following[@"following"] = [[self.listOfFriends objectAtIndex:index] objectId];
    [following saveInBackground];
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inviteSelected {
    self.listOfInvited = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.isSelected count]; i++) {
        if ([self.isSelected[i] boolValue]) {
            [self.listOfInvited addObject:self.listOfFriends[i]];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock(self.listOfInvited);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
