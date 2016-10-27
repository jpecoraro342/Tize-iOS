//
//  GWTSignUpViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 9/24/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTSignUpViewController.h"
#import "GWTBasePageViewController.h"
#import "GWTEventsViewController.h"
#import "GWTNetworkedSettingsManager.h"
#import "GWTSettings.h"
#import "UICKeyChainStore.h"
#import "UIImage+Color.h"
#import <Parse/Parse.h>

@interface GWTSignUpViewController () <PFSignUpViewControllerDelegate>

@end

@implementation GWTSignUpViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        
        self.fields =  PFSignUpFieldsUsernameAndPassword
        | PFSignUpFieldsSignUpButton
        | PFSignUpFieldsDismissButton;
    }
    return self;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [UICKeyChainStore setString:user.username forKey:@"com.currentuser.username" service:@"com.gwt.tize"];
    [UICKeyChainStore setString:self.signUpView.passwordField.text forKey:user.username service:@"com.gwt.tize"];
    [user setObject:@(0) forKey:@"userType"];
    [user saveEventually];
    [[[GWTNetworkedSettingsManager alloc] init] fetchSettings];
    [self loadMainView];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"\nUser could not be signed up: \n%@\n\n", error);
    // [[[UIAlertView alloc] initWithTitle:@"Could Not Register" message:error.userInfo[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)loadMainView {
    GWTBasePageViewController *basePageController = [[GWTBasePageViewController alloc] init];
    
    GWTEventsViewController *events = [[GWTEventsViewController alloc] init];
    basePageController.mainEventsView = events;
    basePageController.currentViewController = events;
    
    [self presentViewController:basePageController animated:YES completion:nil];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo = kLoginLogo;
    logo.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.signUpView setLogo:logo];
    
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageWithColor:kGreenColor] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageWithColor:kDarkerGreenColor] forState:UIControlStateHighlighted];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    CGFloat yoffset = viewWidth/2 - 20 - self.signUpView.logo.frame.size.height;
    
    // Set frame for elements
    [self.signUpView.logo setFrame:CGRectMake(viewWidth/2 - viewWidth/4, self.signUpView.logo.frame.origin.y - 20, viewWidth/2, viewWidth/2)];
    [self.signUpView.usernameField setFrame:CGRectOffset(self.signUpView.usernameField.frame, 0, yoffset)];
    [self.signUpView.passwordField setFrame:CGRectOffset(self.signUpView.passwordField.frame, 0, yoffset)];
    [self.signUpView.signUpButton setFrame:CGRectOffset(self.signUpView.signUpButton.frame, 0, yoffset)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Sign Up Controller"];
}

@end
