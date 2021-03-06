//
//  GWTAttendingTableViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEventBasedViewController.h"

@interface GWTAttendingTableViewController : GWTEventBasedViewController

@property (nonatomic, strong) GWTEvent* event;
@property (nonatomic, strong) NSMutableArray* listOfAttending;
@property (nonatomic, strong) NSMutableArray* listOfMaybeAttending;
@property (nonatomic, strong) NSMutableArray* listOfNotAttending;
@property (nonatomic, strong) NSMutableArray* listOfNotResponded;

@end
