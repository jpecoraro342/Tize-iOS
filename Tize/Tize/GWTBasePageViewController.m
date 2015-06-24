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
#import "GWTViewFactorySingleton.h"


@interface GWTBasePageViewController () <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation GWTBasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 3.0, [UIScreen mainScreen].bounds.size.height);
    
    [self initializeViewControllers];
    
    self.mainEventsView.parentPageController = self;
}

#pragma mark ScrollView

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.currentViewController viewWillDisappear:YES];
    if ([self.currentViewController isEqual:self.mainEventsView]) {
        GWTEvent *event = [self.mainEventsView getEventForTransitionFromGesture:scrollView.gestureRecognizers[1]];
        //NSLog(@"\nScrolling Began: Loading Event Into Views\nEvent: %@\n\n", event);
        if (!event) {
            //cancel scrolling
            self.scrollView.scrollEnabled = NO;
            self.scrollView.scrollEnabled = YES;
    
            //NSLog(@"No Event, Don't Scroll");
            self.noEventDontScroll = YES;
            return;
        }
        self.noEventDontScroll = NO;
        BOOL isEdit = [self setEditOrDetailEventViewWithEvent:event];
        [self updateControllersWithEvent:event];
        
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        
        if (translation.x > 0) {
            if (isEdit) {
                [[self.viewControllers objectAtIndex:0] viewWillAppear:YES];
            }
            else {
                [[self.viewControllers objectAtIndex:1] viewWillAppear:YES];
            }
        }
        else if (translation.x < 0) {
            [[self.viewControllers objectAtIndex:2] viewWillAppear:YES];
        }
    }
    else {
        [self.mainEventsView viewWillAppear:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.noEventDontScroll) {
        [self.scrollView scrollRectToVisible:self.mainEventsView.view.frame animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.currentViewController removeFromParentViewController];
    [self.currentViewController viewDidDisappear:YES];
    
    NSInteger page = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    if (page == 0) {
        self.currentViewController = [[self.viewControllers objectAtIndex:0] view].hidden ? [self.viewControllers objectAtIndex:1] : [self.viewControllers objectAtIndex:0];
    }
    else if (page == 1) {
        self.currentViewController = self.mainEventsView;
    }
    else {
        self.currentViewController = [self.viewControllers objectAtIndex:2];
    }
    [self.currentViewController viewDidAppear:YES];
    [self addChildViewController:self.currentViewController];
    
    NSLog(@"Page Changed\nCurrent View Controller:%@\n\n", self.currentViewController);
}

#pragma mark Private

-(void)initializeViewControllers {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    GWTEditEventViewController *editEvent = [[GWTViewFactorySingleton viewManager] editEventViewController];
    GWTEventDetailViewController *detailEvent = [[GWTEventDetailViewController alloc] init];
    GWTAttendingTableViewController *attending = [[GWTAttendingTableViewController alloc] init];
    
    //Note: Main Events View Controller is not in this list
    self.viewControllers = [[NSMutableArray alloc] initWithObjects:editEvent, detailEvent, attending, nil];
    
    CGRect mainEventsFrame = self.mainEventsView.view.frame;
    mainEventsFrame.origin.x = screenWidth;
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

-(BOOL)setEditOrDetailEventViewWithEvent:(GWTEvent*)event {
    if ([event.host isEqualToString:[[PFUser currentUser] objectId]]) {
        //we are the owner, show the edit event view controller, hide the detail one (note, removing from superview is probably a better option
        //NSLog(@"\nWe are the event owner: show the edit page\n\n");
        [[[self.viewControllers objectAtIndex:0] view] setHidden:NO];
        [[[self.viewControllers objectAtIndex:1] view] setHidden:YES];
        return YES;
    }
    else {
        //we are not the owner, we just want the detail view
        //NSLog(@"\nWe are not the event owner: show the detail page\n\n");
        [[[self.viewControllers objectAtIndex:0] view] setHidden:YES];
        [[[self.viewControllers objectAtIndex:1] view] setHidden:NO];
        return NO;
    }
}

-(void)goForwardToEventsPage {
    [self.currentViewController viewWillDisappear:YES];
    [self.mainEventsView viewWillAppear:YES];
    [self.scrollView scrollRectToVisible:self.mainEventsView.view.frame animated:YES];
    [self.currentViewController viewDidDisappear:YES];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = self.mainEventsView;
    [self addChildViewController:self.currentViewController];
    [self.mainEventsView viewDidAppear:YES];
}

-(void)goBackwardToEventsPage {
    [self goForwardToEventsPage];
}

-(void)deleteEvent:(GWTEvent*)event {
    [self.mainEventsView deleteEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
