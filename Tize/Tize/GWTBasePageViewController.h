//
//  GWTBasePageViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/12/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTEditEventViewController.h"

@class GWTEventsViewController;
@class GWTEvent;

@interface GWTBasePageViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) GWTEventsViewController *mainEventsView;
@property (nonatomic, strong) GWTEditEventViewController *editViewController;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, assign) BOOL noEventDontScroll;
@property (nonatomic, assign) BOOL editEventDontScroll;

-(void)goForwardToEventsPage;
-(void)goBackwardToEventsPage;

-(void)deleteEvent:(GWTEvent*)event;
-(void)createdEvent:(GWTEvent*)event;

@end
