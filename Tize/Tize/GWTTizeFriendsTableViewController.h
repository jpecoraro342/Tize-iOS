//
//  GWTFriendsTableViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEvent.h"

@interface GWTTizeFriendsTableViewController : UIViewController

@property (nonatomic, strong) NSMutableArray* friendsWhoAddedMe;
@property (nonatomic, strong) NSMutableDictionary* friendsIveAdded;

@property (nonatomic, strong) GWTEvent* event;

@end
