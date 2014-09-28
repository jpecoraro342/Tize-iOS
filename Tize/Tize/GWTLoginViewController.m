//
//  GWTLoginViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTLoginViewController.h"
#import "GWTSignUpViewController.h"
#import "GWTEventsViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTEventDetailViewController.h"
#import "GWTAttendingTableViewController.h"
#import "GWTBasePageViewController.h"

@interface GWTLoginViewController () <PFLogInViewControllerDelegate>

@end

@implementation GWTLoginViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.fields = PFLogInFieldsUsernameAndPassword
        | PFLogInFieldsLogInButton
        | PFLogInFieldsSignUpButton
        | PFLogInFieldsPasswordForgotten;
        
        self.delegate = self;
        
        GWTSignUpViewController *signupVC = [[GWTSignUpViewController alloc] init];
        self.signUpController = signupVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"\nUser could not be logged in: \n%@\n\n", error);
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self loadMainView];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}

-(void)loadMainView {
    GWTBasePageViewController *basePageController = [[GWTBasePageViewController alloc] init];
    
    GWTEventsViewController *events = [[GWTEventsViewController alloc] init];
    basePageController.mainEventsView = events;
    basePageController.currentViewController = events;
    
    [self presentViewController:basePageController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
