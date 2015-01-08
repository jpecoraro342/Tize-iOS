//
//  GWTInviteToGroupViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 1/8/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeTableViewController.h"

@class PFObject;
@interface GWTInviteToGroupViewController : GWTTizeTableViewController

@property (nonatomic, copy) void (^dismissBlock)(NSMutableArray* selected);

-(instancetype)initWithGroup:(PFObject *)group;

@end
