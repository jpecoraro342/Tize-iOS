//
//  GWTBasePageViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/12/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWTBasePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

-(void)goForwardToEventsPage;
-(void)goBackwardToEventsPage;

@end
