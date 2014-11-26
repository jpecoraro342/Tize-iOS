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
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = cancel;
    
    [self setViewHasTabBar:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
        case 1:
            return [self.addressBook.listOfContacts count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Tize In My Contacts";
        case 1:
            return @"Add Tize";
    }
    return nil;
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    GWTContact *contact = [self.addressBook.listOfContacts objectAtIndex:indexPath.row];
    return [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    GWTContact *contact = [self.addressBook.listOfContacts objectAtIndex:indexPath.row];
    return contact.listOfPhoneNumbers.firstObject;
}

@end
