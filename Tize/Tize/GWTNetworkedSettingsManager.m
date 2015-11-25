//
//  GWTSettingsManager.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/19/15.
//  Copyright © 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTNetworkedSettingsManager.h"
#import "GWTSettings.h"

@implementation GWTNetworkedSettingsManaager {
    GWTSettings *settingsInParse;
}

static GWTSettings* fetchedSettings;

- (instancetype) init {
    self = [super init];
    if (self) {
        if (fetchedSettings) {
            settingsInParse = fetchedSettings;
        }
        [self fetchSettings];
    }
    return self;
}

-(void)setUserDefaultsFromParseSettings {
    [[NSUserDefaults standardUserDefaults] setBool:settingsInParse.friendRequests forKey:@"newFriendRequestNotification"];
    [[NSUserDefaults standardUserDefaults] setBool:settingsInParse.eventInvites forKey:@"newEventInvitesNotification"];
    [[NSUserDefaults standardUserDefaults] setBool:settingsInParse.upcomingEvents forKey:@"upcomingEventsNotification"];
    [[NSUserDefaults standardUserDefaults] setBool:settingsInParse.inviteResponse forKey:@"invitationResponseNotification"];
}

-(void)updateParseSettingsFromUserDefaults {
    
}

-(void)fetchSettings {
    if (isOrganizationUser) {
        NSLog(@"Trying to load settings for an organization.. No settings to fetch");
        return;
    }
    
    settingsInParse = [[PFUser currentUser] objectForKey:@"userSettings"];
    if (!settingsInParse) {
        settingsInParse = [GWTSettings newSettingsWithDefault];
        [PFUser currentUser][@"userSettings"] = settingsInParse;
        [[PFUser currentUser] saveEventually];
    }
    
    [settingsInParse fetchIfNeededInBackgroundWithBlock:^(PFObject *settings, NSError *error) {
        if (!error) {
            settingsInParse = (GWTSettings *)settings;
            fetchedSettings = settingsInParse;
            [self setUserDefaultsFromParseSettings];
        }
    }];
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
    settingsInParse.friendRequests = friendRequests;
    [settingsInParse saveEventually];
}

-(void)setEventInvites:(BOOL)eventInvites {
    [[NSUserDefaults standardUserDefaults] setBool:eventInvites forKey:@"newEventInvitesNotification"];
    settingsInParse.eventInvites = eventInvites;
    [settingsInParse saveEventually];
}

-(void)setUpcomingEvents:(BOOL)upcomingEvents {
    [[NSUserDefaults standardUserDefaults] setBool:upcomingEvents forKey:@"upcomingEventsNotification"];
    settingsInParse.upcomingEvents = upcomingEvents;
    [settingsInParse saveEventually];
}

-(void)setInviteResponse:(BOOL)inviteResponse {
    [[NSUserDefaults standardUserDefaults] setBool:inviteResponse forKey:@"invitationResponseNotification"];
    settingsInParse.inviteResponse = inviteResponse;
    [settingsInParse saveEventually];
}

@end
