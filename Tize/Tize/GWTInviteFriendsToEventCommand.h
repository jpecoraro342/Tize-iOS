//
//  GWTInviteFriendsToEventCommand.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTCommand.h"

@class PFUser;
@interface GWTInviteFriendsToEventCommand : GWTCommand

@property (nonatomic, strong) NSMutableArray *friendsToInvite;
@property (nonatomic, copy) NSString *eventId;

-(instancetype)initWithEventID:(NSString*)eventId;

-(void)addFriends:(NSMutableArray*)friendsToAdd;
-(void)addFriend:(PFUser*)user;
-(void)removeFriend:(PFUser *)user;
-(void)removeAllFriends;

@end
