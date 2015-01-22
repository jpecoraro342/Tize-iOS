//
//  GWTGroupCommand.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTCommand.h"

@interface GWTGroupCommand : GWTCommand

@property (nonatomic, copy) NSString *groupId;

-(instancetype)initWithGroupID:(NSString*)groupId;

@end