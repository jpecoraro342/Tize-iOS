//
//  GWTGroupsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTGroupsViewController.h"

@interface GWTGroupsViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UITabBarDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation GWTGroupsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        UITabBarItem *groups = self.tabBarItem;
        [groups setTitle:@"Groups"];
        [groups setImage:[UIImage imageNamed:@"groupstab.png"]];
    }
    return self;
}

@end
