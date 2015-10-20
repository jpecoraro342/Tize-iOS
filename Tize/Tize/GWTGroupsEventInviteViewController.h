//
//  GWTGroupsEventInviteViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeSearchTableViewController.h"

@class GWTInviteGroupToEventCommand;
@interface GWTGroupsEventInviteViewController : GWTTizeSearchTableViewController

@property (nonatomic, strong) GWTInviteGroupToEventCommand *groupCommand;

-(void)updateInvitedListFromCommand;

@end
