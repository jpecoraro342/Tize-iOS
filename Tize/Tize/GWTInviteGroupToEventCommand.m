//
//  GWTInviteGroupToEventCommand.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTInviteGroupToEventCommand.h"

@implementation GWTInviteGroupToEventCommand

-(instancetype)initWithEventID:(NSString *)eventId {
    return [self initWithGroupID:@"" eventId:eventId];
}

-(instancetype)initWithGroupID:(NSString *)groupId eventId:(NSString *)eventId {
    self = [super initWithGroupID:groupId];
    if (self) {
        self.eventId = eventId;
    }
    return self;
}

-(void)execute {
    //TODO:
    //get all the user id's of people in that group
    //invite them all to the event
}

@end
