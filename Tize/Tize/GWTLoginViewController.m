//
//  GWTLoginViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "GWTLoginViewController.h"
#import "GWTSignUpViewController.h"
#import "GWTEventsViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTEventDetailViewController.h"
#import "GWTAttendingTableViewController.h"
#import "GWTBasePageViewController.h"
#import "GWTAppDelegate.h"

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
    //[[[UIAlertView alloc] initWithTitle:@"Could Not Log In" message:error.userInfo[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    UIViewController *basePageController = [((GWTAppDelegate*)[[UIApplication sharedApplication] delegate]) setupMainView];
    [self presentViewController:basePageController animated:YES completion:nil];
    [((GWTAppDelegate*)[[UIApplication sharedApplication] delegate]) registerForNotifications];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Login View Controller"];
}

@end
