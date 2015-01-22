//
//  GWTContactsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTInviteFriendsToEventCommand;
@class GWTInviteGroupToEventCommand;
@interface GWTContactsViewController : UITabBarController

@property (nonatomic, strong) GWTInviteFriendsToEventCommand *friendInvites;
@property (nonatomic, strong) GWTInviteGroupToEventCommand *groupInvites;

-(instancetype)initAsEventInviteWithGroupCommand:(GWTInviteGroupToEventCommand*)groupInvites friendCommand:(GWTInviteFriendsToEventCommand*)friendInvites;
-(void)inviteSelected;

@end
