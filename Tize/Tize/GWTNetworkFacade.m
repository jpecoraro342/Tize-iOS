//
//  GWTNetworkFacade.m
//  Tize
//
//  Created by Joseph Pecoraro on 2/17/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import "GWTNetworkFacade.h"
#import "GWTParseNetwork.h"

@implementation GWTNetworkFacade

+(void)makeUsersFollowEachother:(NSString*)userId1 user2:(NSString*)userId2 completionBlock:(GWTBooleanResultBlock)completionBlock {
    [[self getNetworkLayer] createFollowingEventForUser:userId1 followingUser:userId2 completionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[self getNetworkLayer] createFollowingEventForUser:userId2 followingUser:userId1 completionBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                }
                else {
                    //TODO: Handle Error
                }
                completionBlock(succeeded, error);
            }];
        }
        else {
            //TODO: Handle Error
        }
    }];
}


id<GWTNetworking> networkLayer;

+(id<GWTNetworking>)getNetworkLayer {
    if (!networkLayer) {
        networkLayer = [[GWTParseNetwork alloc] init];
    }
    
    return networkLayer;
}

@end
