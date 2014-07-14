//
//  GWTEventsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTEvent;

@interface GWTEventsViewController : UIViewController

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer*)gesture;

@end
