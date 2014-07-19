//
//  GWTBasePageViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/12/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWTEventsViewController;

@interface GWTBasePageViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) GWTEventsViewController *mainEventsView;
@property (nonatomic, strong) UIViewController *currentViewController;

-(void)goForwardToEventsPage;
-(void)goBackwardToEventsPage;

@end
