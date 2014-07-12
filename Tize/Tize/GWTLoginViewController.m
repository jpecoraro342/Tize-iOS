//
//  GWTLoginViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTLoginViewController.h"
#import "GWTEventsViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTEventDetailViewController.h"
#import "GWTAttendingTableViewController.h"
#import "GWTBasePageViewController.h"

@interface GWTLoginViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation GWTLoginViewController

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"\nUser could not be logged in: \n%@\n\n", error);
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    GWTBasePageViewController *basePageController = [[GWTBasePageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    //disable the tap gesture
    for (UIGestureRecognizer *recognizer in basePageController.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }
    
    GWTEventsViewController *events = [[GWTEventsViewController alloc] init];
    
    [basePageController setViewControllers:@[events] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self presentViewController:basePageController animated:YES completion:nil];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    GWTEventsViewController *eventsController = [[GWTEventsViewController alloc] init];
    [self presentViewController:eventsController animated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"\nUser could not be signed up: \n%@\n\n", error);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([PFUser currentUser]) {
        GWTBasePageViewController *basePageController = [[GWTBasePageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        //disable the tap gesture
        for (UIGestureRecognizer *recognizer in basePageController.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                recognizer.enabled = NO;
            }
        }
        
        GWTEventsViewController *events = [[GWTEventsViewController alloc] init];
        
        [basePageController setViewControllers:@[events] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        [self presentViewController:basePageController animated:YES completion:nil];
    }
    else {
        self.delegate = self;
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [self setSignUpController:signUpViewController];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
