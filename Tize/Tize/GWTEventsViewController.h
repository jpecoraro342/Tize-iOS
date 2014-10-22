//
//  GWTEventsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTEvent;
@class GWTBasePageViewController;

@interface GWTEventsViewController : UIViewController

@property (nonatomic, strong) GWTBasePageViewController *parentPageController;

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer*)gesture;

-(void)deleteEvent:(GWTEvent*)event;

@end
