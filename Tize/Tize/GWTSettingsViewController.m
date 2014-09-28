//
//  GWTSettingsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 9/24/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import "GWTSettingsViewController.h"
#import "GWTLoginViewController.h"

@interface GWTSettingsViewController ()

@end

@implementation GWTSettingsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:kNavBarColor];
    self.navigationItem.titleView = kNavBarTitleView;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    self.navigationItem.rightBarButtonItem = done;
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    GWTLoginViewController *login = [[GWTLoginViewController alloc] init];
    [self presentViewController:login animated:YES completion:^{
        self.view.window.rootViewController = login;
    }];
}

-(void)doneEditing {
    //save the settings
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
