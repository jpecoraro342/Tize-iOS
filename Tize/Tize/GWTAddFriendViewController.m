//
//  GWTAddFriendViewController.m
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

@interface GWTAddFriendViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSMutableArray *everybody;

@end

@implementation GWTAddFriendViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        _everybody = [[NSMutableArray alloc] init];
        [self queryEverybody];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddingFriends)];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAddingFriends)];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    navItem.rightBarButtonItem = done;
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
    return 85;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 85)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 85)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [titleLabel setNumberOfLines:4];
    [titleLabel setFont:[UIFont systemFontOfSize:13]];
    
    titleLabel.text = @"These are all the users in the database, in the future it wont look like this, but I figured this was the easiest way to let you add people for now. Just click on a person and youll following them";
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.everybody count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.everybody objectAtIndex:indexPath.row] username];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self addFriendAtIndex:indexPath.row];
}

#pragma mark query

-(void)queryEverybody {
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFUser *object in objects) {
                if ([object.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
                    continue;
                }
                else {
                    [self.everybody addObject:object];
                }
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark Other

-(void)addFriendAtIndex:(NSInteger)index {
    PFObject *following = [PFObject objectWithClassName:@"Following"];
    following[@"user"] = [[PFUser currentUser] objectId];
    following[@"following"] = [[self.everybody objectAtIndex:index] objectId];
    [following saveInBackground];
}

-(void)cancelAddingFriends {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

-(void)doneAddingFriends {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
