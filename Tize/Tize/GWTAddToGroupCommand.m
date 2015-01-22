//
//  GWTAddToGroupCommand.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTAddToGroupCommand.h"
#import <Parse/Parse.h>

@implementation GWTAddToGroupCommand

-(instancetype)initWithListOfFriends:(NSArray *)listOfFriends {
    return [self initWithGroupID:@"" listOfFriends:nil];
}

-(instancetype)initWithGroupID:(NSString *)groupId listOfFriends:(NSArray *)listOfFriends {
    self = [super initWithGroupID:groupId];
    if (self) {
        self.listOfFriends = [listOfFriends mutableCopy];
    }
    return self;
}

-(void)execute {
    NSMutableArray *groupUserObjects = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.listOfFriends count]; i++) {
        PFObject *invite = [PFObject objectWithClassName:@"GroupUsers"];
        invite[@"user"] = [self.listOfFriends objectAtIndex:i];
        invite[@"group"] = [PFObject objectWithoutDataWithClassName:@"Groups" objectId:self.groupId];
        [groupUserObjects addObject:invite];
    }
    NSLog(@"\nInviting %zd friends to \nGroup Id: %@\n\n", [groupUserObjects count], self.groupId);
    [PFObject saveAllInBackground:groupUserObjects block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"\nFriends successfully added to Group!\n\n");
        }
        else {
            NSLog(@"\nError: %@", error.localizedDescription);
        }
    }];
}

@end
