//
//  GWTSettings.h
//  Tize
//
//  Created by Joseph Pecoraro on 9/15/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface GWTSettings : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser* user;

@property (nonatomic, assign) BOOL friendRequests;
@property (nonatomic, assign) BOOL eventInvites;
@property (nonatomic, assign) BOOL upcomingEvents;
@property (nonatomic, assign) BOOL inviteResponse;

+(NSString*)parseClassName;

@end