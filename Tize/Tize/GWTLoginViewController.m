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
#import "UIImage+Color.h"
#import "UICKeyChainStore.h"

@interface GWTLoginViewController () <PFLogInViewControllerDelegate>

@end

@implementation GWTLoginViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.fields = PFLogInFieldsUsernameAndPassword
        | PFLogInFieldsLogInButton
        | PFLogInFieldsSignUpButton;
        
        self.delegate = self;
        
        GWTSignUpViewController *signupVC = [[GWTSignUpViewController alloc] init];
        self.signUpController = signupVC;
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo = kLoginLogo;
    logo.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.logInView setLogo:logo];
    
    [self.logInView.logInButton setBackgroundImage:[UIImage imageWithColor:kGreenColor] forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:[UIImage imageWithColor:kDarkerGreenColor] forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageWithColor:kGrayColor] forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:[UIImage imageWithColor:kDarkGrayColor] forState:UIControlStateHighlighted];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    CGFloat yoffset = viewWidth/2 - 20 - self.logInView.logo.frame.size.height;
    
    // Set frame for elements
    [self.logInView.logo setFrame:CGRectMake(viewWidth/2 - viewWidth/4, self.logInView.logo.frame.origin.y - 20, viewWidth/2, viewWidth/2)];
    [self.logInView.usernameField setFrame:CGRectOffset(self.logInView.usernameField.frame, 0, yoffset)];
    [self.logInView.passwordField setFrame:CGRectOffset(self.logInView.passwordField.frame, 0, yoffset)];
    [self.logInView.logInButton setFrame:CGRectOffset(self.logInView.logInButton.frame, 0, yoffset)];
}

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"\nUser could not be logged in: \n%@\n\n", error);
    //[[[UIAlertView alloc] initWithTitle:@"Could Not Log In" message:error.userInfo[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [UICKeyChainStore setString:user.username forKey:@"com.currentuser.username" service:@"com.gwt.tize"];
    [UICKeyChainStore setString:self.logInView.passwordField.text forKey:user.username service:@"com.gwt.tize"];
    
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
