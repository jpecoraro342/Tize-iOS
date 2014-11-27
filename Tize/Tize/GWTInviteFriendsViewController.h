//
//  GWTInviteFriendsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 9/28/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEvent.h"

@interface GWTInviteFriendsViewController : UIViewController

@property (nonatomic, copy) void (^dismissBlock)(NSMutableArray* invited);
@property (nonatomic, strong) GWTEvent *event;

-(instancetype)initWithEvent:(GWTEvent *)event;

@end
