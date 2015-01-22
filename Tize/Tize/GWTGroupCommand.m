//
//  GWTGroupCommand.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTGroupCommand.h"

@implementation GWTGroupCommand

-(instancetype)init {
    return [self initWithGroupID:@""];
}

-(instancetype)initWithGroupID:(NSString *)groupId {
    self = [super init];
    if (self) {
        self.groupId = groupId;
    }
    return self;
}

@end
