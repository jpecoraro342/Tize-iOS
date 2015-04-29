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

@interface GWTEventsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) GWTBasePageViewController *parentPageController;

-(GWTEvent*)getEventForTransitionFromGesture:(UIGestureRecognizer*)gesture;

-(void)deleteEvent:(GWTEvent*)event;

-(GWTEvent *)eventForIndexPath:(NSIndexPath*)indexPath;
-(UIImage*)iconForIndexPath:(NSIndexPath*)indexPath;

#pragma mark - Queries
-(void)queryData;
-(void)queryEvents;
-(void)queryOtherEvents;
-(void)queryMyEvents;
-(void)queryAttendingStatus;

@end
