//
//  GWTInviteFriendsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 9/28/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWTInviteFriendsViewController : UIViewController

@property (nonatomic, copy) void (^dismissBlock)(NSMutableArray* invited);

@end
