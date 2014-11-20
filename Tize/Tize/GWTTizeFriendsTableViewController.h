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

@property (nonatomic, strong) NSMutableArray* listOfFriends;
@property (nonatomic, strong) NSMutableArray* listOfGroups;
@property (nonatomic, strong) NSMutableArray* listOfOrganizations;

@property (nonatomic, strong) GWTEvent* event;

@end
