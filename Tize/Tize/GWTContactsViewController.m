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

#import "GWTInviteFriendsViewController.h"
#import "GWTGroupsEventInviteViewController.h"
#import "GWTInviteFriendsToEventCommand.h"
#import "GWTInviteGroupToEventCommand.h"

@implementation GWTContactsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self.tabBar setTintColor:kGreenColor];
        [self loadTabs];
    }
    return self;
}

-(instancetype)initAsEventInviteWithGroupCommand:(GWTInviteGroupToEventCommand *)groupInvites friendCommand:(GWTInviteFriendsToEventCommand *)friendInvites {
    self = [super init];
    if (self) {
        [self.tabBar setTintColor:kGreenColor];
        self.groupInvites = groupInvites;
        self.friendInvites = friendInvites;
        [self loadEventInviteTabs];
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

-(void)loadEventInviteTabs {
    GWTInviteFriendsViewController *friends = [[GWTInviteFriendsViewController alloc] init];
    // GWTContactsListViewController *contacts = [[GWTContactsListViewController alloc] init];
    GWTGroupsEventInviteViewController *groups = [[GWTGroupsEventInviteViewController alloc] init];
    
    friends.inviteCommand = self.friendInvites;
    groups.groupCommand = self.groupInvites;
    
    [friends updateInvitedListFromCommand];
    [groups updateInvitedListFromCommand];
    
    [self setViewControllers:@[friends, groups]];
    [self setSelectedViewController:friends];
}

-(void)inviteSelected {
    [self.friendInvites execute];
    [self.groupInvites execute];
}

@end
