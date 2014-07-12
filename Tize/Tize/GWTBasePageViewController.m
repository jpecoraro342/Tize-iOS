//
//  GWTBasePageViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 7/12/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTBasePageViewController.h"
#import "GWTEventsViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTEventDetailViewController.h"
#import "GWTAttendingTableViewController.h"


@interface GWTBasePageViewController ()

@end

@implementation GWTBasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark pageviewcontroller datasource methods

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[GWTEventsViewController class]]) {
        return [[GWTEditEventViewController alloc] init];
    }
    else if ([viewController isKindOfClass:[GWTAttendingTableViewController class]]) {
        return [[GWTEventsViewController alloc] init];
    }
    else {
        return nil;
    }
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[GWTEventsViewController class]]) {
        return [[GWTAttendingTableViewController alloc] init];
    }
    else if ([viewController isKindOfClass:[GWTAttendingTableViewController class]]) {
        return nil;
    }
    else {
        return [[GWTEventsViewController alloc] init];
    }
}

#pragma mark pageviewcontroller delegate methods

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    NSLog(@"Transitioning\n\n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
