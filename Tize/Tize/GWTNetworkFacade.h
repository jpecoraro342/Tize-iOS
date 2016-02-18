//
//  GWTNetworkFacade.h
//  Tize
//
//  Created by Joseph Pecoraro on 2/17/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTNetworking.h"

@interface GWTNetworkFacade : NSObject


+(void)makeUsersFollowEachother:(NSString*)userId1 user2:(NSString*)userId2 completionBlock:(GWTBooleanResultBlock)completionBlock;

@end
