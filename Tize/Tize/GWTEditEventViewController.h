//
//  GWTEditEventViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEvent.h"
#import "GWTEventBasedViewController.h"

@class GWTInviteFriendsToEventCommand;
@class GWTInviteGroupToEventCommand;
@interface GWTEditEventViewController : GWTEventBasedViewController <UITableViewDataSource, UITableViewDelegate>

@property GWTEvent* event;

@property (nonatomic, strong) GWTInviteFriendsToEventCommand *friendInvites;
@property (nonatomic, strong) GWTInviteGroupToEventCommand *groupInvites;

-(void)updateEvent;
-(void)sendOutInvites:(GWTEvent*)event;

@end
