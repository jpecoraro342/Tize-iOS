//
//  GWTParseNetwork.m
//  Tize
//
//  Created by Joseph Pecoraro on 2/17/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import "GWTParseNetwork.h"
#import "Parse.h"

@implementation GWTParseNetwork

-(void)createFollowingEventForUser:(NSString*)followerUserId followingUser:(NSString*)userId completionBlock:(GWTBooleanResultBlock)completionBlock {
    PFObject *following = [PFObject objectWithClassName:@"Following"];
    following[@"user"] = followerUserId;
    following[@"following"] = userId;
    [following saveInBackgroundWithBlock:completionBlock];
}

@end
