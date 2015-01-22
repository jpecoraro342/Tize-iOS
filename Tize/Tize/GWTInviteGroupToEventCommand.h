//
//  GWTInviteGroupToEventCommand.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTGroupCommand.h"
#import <Parse/Parse.h>

@interface GWTInviteGroupToEventCommand : GWTGroupCommand

@property (nonatomic, copy) NSString* eventId;
@property (nonatomic, strong) NSMutableArray *listOfGroups;
@property (nonatomic, strong) NSMutableArray *listOfPeopleInGroups;

-(instancetype)initWithEventID:(NSString*)eventId;
-(instancetype)initWithGroupID:(NSString *)groupId eventId:(NSString*)eventId;

-(void)addGroups:(NSMutableArray*)groups;
-(void)addGroup:(PFObject*)group;
-(void)removeGroup:(PFObject *)group;

@end
