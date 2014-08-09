//
//  GWTEventDetailViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEvent.h"
#import "GWTEventBasedViewController.h"

@interface GWTEventDetailViewController : GWTEventBasedViewController

@property GWTEvent* event;
@property PFObject* currentAttendingStatus;

@end
