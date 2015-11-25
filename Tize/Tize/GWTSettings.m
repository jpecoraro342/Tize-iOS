//
//  GWTSettings.m
//  Tize
//
//  Created by Joseph Pecoraro on 9/15/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTSettings.h"

@implementation GWTSettings

@dynamic user;
@dynamic friendRequests;
@dynamic eventInvites;
@dynamic upcomingEvents;
@dynamic inviteResponse;

+(NSString*)parseClassName {
    return @"Settings";
}

+(GWTSettings*)newSettingsWithDefault {
    GWTSettings *newSettings = [[GWTSettings alloc] initWithClassName:@"Settings"];
    
    newSettings.friendRequests = YES;
    newSettings.eventInvites = YES;
    newSettings.upcomingEvents = YES;
    newSettings.inviteResponse = NO;
    
    return newSettings;
}

@end
