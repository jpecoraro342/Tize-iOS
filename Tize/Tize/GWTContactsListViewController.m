//
//  GWTContactsListViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTContactsListViewController.h"
#import "GWTAddressBook.h"

@interface GWTContactsListViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UITabBarDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation GWTContactsListViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
        self.addressBook = [[GWTAddressBook alloc] init];
    }
    return self;
}

@end
