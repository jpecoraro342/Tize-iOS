//
//  GWTInviteGroupToEventCommand.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTGroupCommand.h"

@interface GWTInviteGroupToEventCommand : GWTGroupCommand

@property (nonatomic, copy) NSString* eventId;

-(instancetype)initWithEventID:(NSString*)eventId;
-(instancetype)initWithGroupID:(NSString *)groupId eventId:(NSString*)eventId;

@end
