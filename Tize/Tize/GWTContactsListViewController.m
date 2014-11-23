//
//  GWTContactsListViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTContactsListViewController.h"
#import "GWTAddressBook.h"
#import "GWTContact.h"

@interface GWTContactsListViewController () <UITabBarDelegate, UITabBarControllerDelegate>

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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewHasTabBar:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addressBook.listOfContacts count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"Contacts";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    GWTContact *contact = [self.addressBook.listOfContacts objectAtIndex:indexPath.row];
    return [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
}



@end
