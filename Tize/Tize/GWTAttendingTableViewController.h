//
//  GWTAttendingTableViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTEvent;

@interface GWTAttendingTableViewController : UIViewController

@property GWTEvent* event;

-(instancetype)initWithEvent:(GWTEvent*)event;

@end
