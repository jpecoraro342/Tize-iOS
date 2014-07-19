//
//  GWTEventBasedViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/19/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GWTEvent;

/*
 This is an abstract class meant for subclassing. This characterizes a viewcontroller that manages a single event
 */
@interface GWTEventBasedViewController : UIViewController

-(void)reloadWithEvent:(GWTEvent*)event;

@end
