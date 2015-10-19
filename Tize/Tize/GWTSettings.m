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

@end
