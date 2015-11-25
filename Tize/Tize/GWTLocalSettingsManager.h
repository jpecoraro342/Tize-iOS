//
//  GWTLocalSettingsManager.h
//  Tize
//
//  Created by Joseph Pecoraro on 11/19/15.
//  Copyright © 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTSettingsManager.h"

@interface GWTLocalSettingsManager : NSObject <GWTSettingsManager>

@property (nonatomic, assign) BOOL friendRequests;
@property (nonatomic, assign) BOOL eventInvites;
@property (nonatomic, assign) BOOL upcomingEvents;
@property (nonatomic, assign) BOOL inviteResponse;

@end
