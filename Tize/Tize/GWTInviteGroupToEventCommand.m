//
//  GWTInviteGroupToEventCommand.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTInviteGroupToEventCommand.h"
#import "GWTInviteFriendsToEventCommand.h"

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
    
    [self queryInGroup];
}

-(void)queryInGroup {
    PFQuery *groupUsers = [PFQuery queryWithClassName:@"GroupUsers"];
    [groupUsers whereKey:@"group" containedIn:self.listOfGroups];
    [groupUsers includeKey:@"user"];
    [groupUsers findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            NSMutableDictionary *friendsInGroup = [[NSMutableDictionary alloc] initWithCapacity:[objects count]]; //for those ugly dups
            self.listOfPeopleInGroups = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (PFUser *object in objects) {
                PFUser *user = object[@"user"];
                [friendsInGroup setObject:user forKey:[user objectId]];
            }
            //To handle duplicates -- ughh!
            [friendsInGroup enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self.listOfPeopleInGroups addObject:obj];
            }];
            
            [self inviteAllToEvent];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

-(void)inviteAllToEvent {
    GWTInviteFriendsToEventCommand *invite = [[GWTInviteFriendsToEventCommand alloc] initWithEventID:self.eventId];
    [invite addFriends:self.listOfPeopleInGroups];
    [invite execute];
    
    [self.listOfGroups removeAllObjects];
    [self.listOfPeopleInGroups removeAllObjects];
}

@end
