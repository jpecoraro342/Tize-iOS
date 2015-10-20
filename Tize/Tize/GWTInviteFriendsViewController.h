//
//  GWTInviteFriendsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 9/28/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEvent.h"
#import "GWTTizeSearchTableViewController.h"

@class GWTInviteFriendsToEventCommand;
@interface GWTInviteFriendsViewController : GWTTizeSearchTableViewController

@property (nonatomic, strong) GWTEvent *event;
@property (nonatomic, strong) GWTInviteFriendsToEventCommand *inviteCommand;

-(instancetype)initWithEvent:(GWTEvent *)event;

-(void)updateInvitedListFromCommand;

@end
