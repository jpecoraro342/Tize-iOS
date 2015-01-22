//
//  GWTGroupsEventInviteViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeTableViewController.h"

@class GWTInviteGroupToEventCommand;
@interface GWTGroupsEventInviteViewController : GWTTizeTableViewController

@property (nonatomic, strong) GWTInviteGroupToEventCommand *groupCommand;

@end
