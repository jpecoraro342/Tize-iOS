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
    [self loadMainView];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"\nUser could not be signed up: \n%@\n\n", error);
    [[[UIAlertView alloc] initWithTitle:@"Could Not Register" message:error.userInfo[@"error"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)loadMainView {
    GWTBasePageViewController *basePageController = [[GWTBasePageViewController alloc] init];
    
    GWTEventsViewController *events = [[GWTEventsViewController alloc] init];
    basePageController.mainEventsView = events;
    basePageController.currentViewController = events;
    
    [self presentViewController:basePageController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Sign Up Controller"];
}

@end
