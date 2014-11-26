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
        _listOfFriends = [[NSMutableArray alloc] init];
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
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    
    
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
    
    UIButton *addItem = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 50, 2, 36, 36)];
    [addItem setImage:[UIImage imageNamed:@"plus" withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    switch (section) {
        case 0: {
            titleLabel.text = @"Friends";
            [addItem addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:addItem];
            break;
        }
        case 1:
            titleLabel.text = @"My Groups";
            [addItem addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:addItem];
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
            return [self.listOfGroups count];
        case 2:
            return [self.listOfOrganizations count];
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row < [self.listOfFriends count]) {
                cell.textLabel.text = [[self.listOfFriends objectAtIndex:indexPath.row] username];
            }
            break;
        }
        case 1: {
            if (indexPath.row < [self.listOfGroups count]) {
                //cell.textLabel.text = [[self.listOfGroups objectAtIndex:indexPath.row] groupName];
            }
            break;
        }
        case 2: {
            if (indexPath.row < [self.listOfOrganizations count]) {
                cell.textLabel.text = [self.listOfOrganizations objectAtIndex:indexPath.row][@"name"];
            }
            break;
        }
        default:
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark query

-(void)queryFollowing {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        self.listOfFriends = [[NSMutableArray alloc] init];
        if(!error) {
            for (PFUser *object in objects) {
                [self.listOfFriends addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

-(void)queryGroups {
    
}

-(void)queryOrganizations {
    PFQuery *getAllOrganizationFollowingEvents = [PFQuery queryWithClassName:@"OrganizationFollowers"];
    PFQuery *getAllOrganizationsWeAreFollowing = [PFQuery queryWithClassName:@"Organization"];
    [getAllOrganizationFollowingEvents whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [getAllOrganizationsWeAreFollowing whereKey:@"objectId" matchesKey:@"organizationID" inQuery:getAllOrganizationFollowingEvents];
    [getAllOrganizationsWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listOfOrganizations = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else {
            
        }
    }];
}

#pragma mark Other

-(void)queryAll {
    [self queryFollowing];
    [self queryGroups];
    [self queryOrganizations];
}

-(void)addFriends {
    GWTAddFriendViewController *addFriends = [[GWTAddFriendViewController alloc] init];
    addFriends.dismissBlock = ^{
        [self queryFollowing];
    };
    [self presentViewController:addFriends animated:YES completion:nil];
}

-(void)createGroup {
    [[[UIAlertView alloc] initWithTitle:@"I'm not that good" message:@"Woah there buddy, don't get ahead of yourself. I'm not that far along yet" delegate:self cancelButtonTitle:@"Hurry up Joe!" otherButtonTitles:nil] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"List of Friends VC"];
}


@end