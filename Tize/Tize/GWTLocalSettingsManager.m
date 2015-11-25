//
//  GWTSettingsManager.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/19/15.
//  Copyright © 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTLocalSettingsManager.h"
#import "GWTSettings.h"

@implementation GWTLocalSettingsManager

- (instancetype) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


# pragma mark - Property Definitions

-(BOOL)friendRequests {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"newFriendRequestNotification"];
}

-(BOOL)eventInvites {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"newEventInvitesNotification"];
}

-(BOOL)upcomingEvents {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"upcomingEventsNotification"];
}

-(BOOL)inviteResponse {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"invitationResponseNotification"];
}

-(void)setFriendRequests:(BOOL)friendRequests {
    [[NSUserDefaults standardUserDefaults] setBool:friendRequests forKey:@"newFriendRequestNotification"];
}

-(void)setEventInvites:(BOOL)eventInvites {
    [[NSUserDefaults standardUserDefaults] setBool:eventInvites forKey:@"newEventInvitesNotification"];
}

-(void)setUpcomingEvents:(BOOL)upcomingEvents {
    [[NSUserDefaults standardUserDefaults] setBool:upcomingEvents forKey:@"upcomingEventsNotification"];
}

-(void)setInviteResponse:(BOOL)inviteResponse {
    [[NSUserDefaults standardUserDefaults] setBool:inviteResponse forKey:@"invitationResponseNotification"];
}

@end
