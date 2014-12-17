//
//  GWTContactsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTContactsViewController.h"
#import "GWTTizeFriendsTableViewController.h"
#import "GWTContactsListViewController.h"
#import "GWTGroupsViewController.h"

@implementation GWTContactsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self.tabBar setTintColor:kGreenColor];
        [self loadTabs];
    }
    return self;
}

-(void)loadTabs {
    GWTTizeFriendsTableViewController *friends = [[GWTTizeFriendsTableViewController alloc] init];
    GWTContactsListViewController *contacts = [[GWTContactsListViewController alloc] init];
    GWTGroupsViewController *groups = [[GWTGroupsViewController alloc] init];
    
    [self setViewControllers:@[friends, contacts, groups]];
    [self setSelectedViewController:friends];
}

@end
