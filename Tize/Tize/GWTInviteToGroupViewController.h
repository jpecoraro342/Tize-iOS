//
//  GWTInviteToGroupViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/8/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeSearchTableViewController.h"

@class GWTAddToGroupCommand;
@class PFObject;
@interface GWTInviteToGroupViewController : GWTTizeSearchTableViewController

@property (nonatomic, strong) GWTAddToGroupCommand *inviteFriendsCommand;

-(instancetype)initWithGroup:(PFObject *)group;

@end
