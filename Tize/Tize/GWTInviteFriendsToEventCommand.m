//
//  GWTInviteFriendsToEventCommand.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTInviteFriendsToEventCommand.h"
#import <Parse/Parse.h>

@implementation GWTInviteFriendsToEventCommand

-(instancetype)initWithEventID:(NSString*)eventId {
    self = [super init];
    if (self) {
        self.eventId = eventId;
    }
    return self;
}

-(void)addFriends:(NSMutableArray *)friendsToAdd {
    [self.friendsToInvite addObjectsFromArray:friendsToAdd];
}

-(void)addFriend:(PFUser *)user {
    [self.friendsToInvite addObject:user];
}

-(void)removeFriend:(PFUser *)user {
    [self.friendsToInvite removeObject:user];
}

-(void)execute {
    NSMutableArray *eventUserObjects = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.friendsToInvite count]; i++) {
        PFObject *invite = [PFObject objectWithClassName:@"EventUsers"];
        invite[@"userID"] = [[self.friendsToInvite objectAtIndex:i] objectId];
        invite[@"attendingStatus"] = [NSNumber numberWithInt:3];
        invite[@"eventID"] = self.eventId;
        [eventUserObjects addObject:invite];
    }
    
    NSLog(@"\nInviting %zd friends to \nEvent: %@\n\n", [eventUserObjects count], self.eventId);
    [PFObject saveAllInBackground:eventUserObjects block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"\nFriends successfully invited!\n\n");
        }
        else {
            NSLog(@"\nError: %@", error.localizedDescription);
        }
    }];
}

@end
