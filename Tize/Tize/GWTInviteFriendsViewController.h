//
//  GWTInviteFriendsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 9/28/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEvent.h"
#import "GWTTizeTableViewController.h"

@class GWTInviteFriendsToEventCommand;
@interface GWTInviteFriendsViewController : GWTTizeTableViewController

@property (nonatomic, strong) GWTEvent *event;
@property (nonatomic, strong) GWTInviteFriendsToEventCommand *inviteCommand;

-(instancetype)initWithEvent:(GWTEvent *)event;

@end
