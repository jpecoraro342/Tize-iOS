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

#pragma mark ScrollView

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    GWTEvent *event = [self.mainEventsView getEventForTransitionFromGesture:scrollView.gestureRecognizers[1]];
    NSLog(@"\nScrolling Began: Loading Event Into Views\nEvent: %@\n\n", event);
    [self updateControllersWithEvent:event];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"\nPage Changed: Set up the current view controller\n\n");
}

#pragma mark Private

-(void)initializeViewControllers {
    GWTEditEventViewController *editEvent = [[GWTEditEventViewController alloc] init];
    GWTEventDetailViewController *detailEvent = [[GWTEventDetailViewController alloc] init];
    GWTAttendingTableViewController *attending = [[GWTAttendingTableViewController alloc] init];
    
    //Note: Main Events View Controller is not in this list
    self.viewControllers = [[NSMutableArray alloc] initWithObjects:editEvent, detailEvent, attending, nil];
    
    CGRect mainEventsFrame = self.mainEventsView.view.frame;
    mainEventsFrame.origin.x = 320;
    self.mainEventsView.view.frame = mainEventsFrame;
    [self.scrollView addSubview:self.mainEventsView.view];
    
    [self.scrollView scrollRectToVisible:mainEventsFrame animated:NO];
    
    CGRect attendingFrame = attending.view.frame;
    attendingFrame.origin.x = 640;
    attending.view.frame = attendingFrame;
    
    for (UIViewController *vc in self.viewControllers) {
        [self.scrollView addSubview:vc.view];
    }
    
}

-(void)updateControllersWithEvent:(GWTEvent*)event {
    for (GWTEventBasedViewController *vc in self.viewControllers) {
        [vc reloadWithEvent:event];
    }
}

-(void)goForwardToEventsPage {
    [self.scrollView scrollRectToVisible:self.mainEventsView.view.frame animated:YES];
}

-(void)goBackwardToEventsPage {
    [self.scrollView scrollRectToVisible:self.mainEventsView.view.frame animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
