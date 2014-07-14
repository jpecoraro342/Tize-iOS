//
//  GWTBasePageViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/12/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTEventsViewController;

@interface GWTBasePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) GWTEventsViewController *mainEventsView;
@property (nonatomic, strong) UIPanGestureRecognizer *transitionDetector;

-(void)goForwardToEventsPage;
-(void)goBackwardToEventsPage;

@end
