//
//  GWTFriendsTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeFriendsTableViewController.h"
#import "GWTSettingsViewController.h"
#import "GWTEventsViewController.h"
#import "GWTAddFriendViewController.h"
#import "UIImage+Color.h"

@interface GWTTizeFriendsTableViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UITabBarDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation GWTTizeFriendsTableViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self queryAll];
        UITabBarItem *tize = self.tabBarItem;
        [tize setTitle:@"My Tize"];
        [tize setImage:[UIImage imageNamed:@"logo_tab_bar.png"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.leftBarButtonItem = cancel;
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setTintColor:kNavBarTintColor];
    [self.navigationBar setBarTintColor:kNavBarColor];
    
    //[self.view addSubview:toolbar];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

-(void)dismiss {
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
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    switch (section) {
        case 0: {
            titleLabel.text = @"Tize Requests";
            break;
        }
    }
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.friendsWhoAddedMe count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row < [self.friendsWhoAddedMe count]) {
                PFUser *userFollowing = [self.friendsWhoAddedMe objectAtIndex:indexPath.row];
                cell.textLabel.text = [userFollowing username];
                cell.accessoryType = [self.friendsIveAdded objectForKey:[userFollowing objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFUser *friend = [self.friendsWhoAddedMe objectAtIndex:indexPath.row];
    if ([self.friendsIveAdded objectForKey:[friend objectId]]) {
        [self removeFriendAtIndexPath:indexPath];
    }
    else {
        [self addFriendAtIndexPath:indexPath];
    }
}

#pragma mark query

-(void)queryAll {
    [self queryMyFollowing];
    [self queryFollingMe];
}

-(void)queryFollingMe {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersFollowingMe = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"following" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersFollowingMe whereKey:@"objectId" matchesKey:@"user" inQuery:getAllFollowingEvents];
    [getAllUsersFollowingMe findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        self.friendsWhoAddedMe = [[NSMutableArray alloc] init];
        if(!error) {
            for (PFUser *object in objects) {
                [self.friendsWhoAddedMe addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

-(void)queryMyFollowing {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        self.friendsIveAdded = [[NSMutableDictionary alloc] init];
        if(!error) {
            for (PFUser *object in objects) {
                [self.friendsIveAdded setObject:object forKey:[object objectId]];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark Other

-(void)addFriendAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFUser *user = [self.friendsWhoAddedMe objectAtIndex:indexPath.row];
    PFObject *following = [PFObject objectWithClassName:@"Following"];
    following[@"user"] = [[PFUser currentUser] objectId];
    following[@"following"] = [user objectId];
    [following saveInBackground];
    
    [self.friendsIveAdded setObject:user forKey:[user objectId]];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.friendsWhoAddedMe objectAtIndex:indexPath.row];
    [self.friendsIveAdded removeObjectForKey:[user objectId]];
    //TODO:Write the code to remove a friend
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"List of Friends VC"];
}


@end
