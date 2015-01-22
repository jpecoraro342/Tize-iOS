//
//  GWTAddToGroupCommand.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTGroupCommand.h"

@interface GWTAddToGroupCommand : GWTGroupCommand

@property (nonatomic, strong) NSMutableArray *listOfFriends;

-(instancetype)initWithListOfFriends:(NSArray*)listOfFriends;
-(instancetype)initWithGroupID:(NSString *)groupId listOfFriends:(NSArray*)listOfFriends;

@end
