//
//  GWTInviteGroupToEventCommand.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTInviteGroupToEventCommand.h"

@implementation GWTInviteGroupToEventCommand

-(instancetype)init {
    return [self initWithGroupID:@"" eventId:@""];
}

-(instancetype)initWithEventID:(NSString *)eventId {
    return [self initWithGroupID:@"" eventId:eventId];
}

-(instancetype)initWithGroupID:(NSString *)groupId eventId:(NSString *)eventId {
    self = [super initWithGroupID:groupId];
    if (self) {
        self.eventId = eventId;
        self.listOfGroups = [NSMutableArray array];
    }
    return self;
}

-(void)addGroups:(NSMutableArray *)groups {
    [self.listOfGroups addObjectsFromArray:groups];
}

-(void)addGroup:(PFObject *)group {
    [self.listOfGroups addObject:group];
}

-(void)removeGroup:(PFObject *)group {
    [self.listOfGroups removeObject:group];
}

-(void)execute {
    if (!self.eventId || [self.eventId isEqualToString:@""]) {
        return;
    }
    //TODO:
    //get all the user id's of people in that group
    //invite them all to the event
    [self.listOfGroups removeAllObjects];
}

@end
