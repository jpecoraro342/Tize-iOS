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


@interface GWTBasePageViewController () <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation GWTBasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3.0, self.scrollView.frame.size.height);
    
    [self initializeViewControllers];
    
    self.mainEventsView.parentPageController = self;
}

#pragma mark pageviewcontroller datasource methods

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    /*if ([viewController isKindOfClass:[GWTEventsViewController class]]) {
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
    }*/
    return nil;
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

#pragma mark ScrollView

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"\nPage Changed");
}

#pragma mark Private

-(void)initializeViewControllers {
    GWTEditEventViewController *editEvent = [[GWTEditEventViewController alloc] init];
    GWTEventDetailViewController *detailEvent = [[GWTEventDetailViewController alloc] init];
    GWTAttendingTableViewController *attending = [[GWTAttendingTableViewController alloc] init];
    
    self.viewControllers = [[NSMutableArray alloc] initWithObjects:editEvent, detailEvent, self.mainEventsView, attending, nil];
    
    CGRect mainEventsFrame = self.mainEventsView.view.frame;
    mainEventsFrame.origin.x = 320;
    self.mainEventsView.view.frame = mainEventsFrame;
    
    [self.scrollView scrollRectToVisible:mainEventsFrame animated:NO];
    
    CGRect attendingFrame = attending.view.frame;
    attendingFrame.origin.x = 640;
    attending.view.frame = attendingFrame;
    
    for (UIViewController *vc in self.viewControllers) {
        [self.scrollView addSubview:vc.view];
    }
    
}

-(void)goForwardToEventsPage {
    //self scrolltopage self.mainEventsView (go forward)
}

-(void)goBackwardToEventsPage {
    //self scrolltopage self.mainEventsView (in reverse)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
