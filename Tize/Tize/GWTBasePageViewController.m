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
    
    self.mainEventsView.parentPageController = self;
    
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark pageviewcontroller datasource methods

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[GWTEventsViewController class]]) {
        GWTEvent* toEvent = [self.mainEventsView getEventForTransitionFromGesture:self.transitionDetector];
        NSLog(@"\nWe are currently on the events page, transition to view with event: %@\n\n", toEvent.eventName);
        UIViewController *previousPage;
        if ([toEvent.host isEqualToString:[PFUser currentUser].objectId]) {
            NSLog(@"\nThe event host is equal to the current user, we want an edit event page\n\n");
            previousPage = [[GWTEditEventViewController alloc] init]; //initWithEvent?
        }
        else {
            NSLog(@"\nThe event host is not the same as the current user, take us to the event detail page\n\n");
            previousPage = [[GWTEventDetailViewController alloc] init];
        }
        return previousPage;
    }
    else if ([viewController isKindOfClass:[GWTAttendingTableViewController class]]) {
        return self.mainEventsView;
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
        return self.mainEventsView;
    }
}

#pragma mark pageviewcontroller delegate methods

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    if (![pendingViewControllers.firstObject isKindOfClass:[GWTEventsViewController class]]) {
        GWTEvent* toEvent = [self.mainEventsView getEventForTransitionFromGesture:self.transitionDetector];
        /*NSLog(@"\nWill transition to view with event name: %@\n\n", toEvent.eventName);
        if (toEvent) {
            [pendingViewControllers.firstObject reloadWithEvent:toEvent];
        }*/
        [pendingViewControllers.firstObject reloadWithEvent:toEvent];
    }
}

#pragma mark private methods

-(void)setNeedsUpdate {
    [self setViewControllers:self.viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setViewControllers:self.viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    });
}

-(void)goForwardToEventsPage {
    [self setViewControllers:@[[[GWTEventsViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)goBackwardToEventsPage {
    [self setViewControllers:@[[[GWTEventsViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
