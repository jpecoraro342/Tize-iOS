//
//  GWTBasePageViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/12/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTEventsViewController;
@class GWTEvent;

@interface GWTBasePageViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) GWTEventsViewController *mainEventsView;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, assign) BOOL noEventDontScroll;

-(void)goForwardToEventsPage;
-(void)goBackwardToEventsPage;

-(void)deleteEvent:(GWTEvent*)event;

@end
