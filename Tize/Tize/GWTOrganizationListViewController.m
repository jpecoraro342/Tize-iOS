//
//  GWTOrganizationListViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTOrganizationListViewController.h"
#import "Parse.h"
#import "SVProgressHUD.h"
#import "GWTAppDelegate.h"
#import "UICKeyChainStore.h"

@interface GWTOrganizationListViewController ()

@property (nonatomic, strong) NSMutableArray *listOfOrganizations;
@property (nonatomic, assign) BOOL queryFinished;

@end

@implementation GWTOrganizationListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self queryOrganizations];
}

#pragma mark - TizeTableViewOverrides

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfOrganizations count] == 0 && self.queryFinished ? 1 : [self.listOfOrganizations count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"Organizations";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    if ([self.listOfOrganizations count] == 0 && self.queryFinished) {
        return @"Could not find any Organizations";
    }
    else {
        return [[self.listOfOrganizations objectAtIndex:indexPath.row] username];
    }
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

-(void)selectedItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.listOfOrganizations count] != 0) {
        [self switchToUser:[self.listOfOrganizations objectAtIndex:indexPath.row]];
    }
}

#pragma mark - Private Methods

-(void)queryOrganizations {
    PFQuery *adminOrganizations = [PFQuery queryWithClassName:@"OrganizationAdmins"];
    [adminOrganizations whereKey:@"admin" equalTo:[PFUser currentUser]];
    [adminOrganizations includeKey:@"organization"];
    
    [adminOrganizations findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listOfOrganizations = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (PFObject *object in objects) {
                [self.listOfOrganizations addObject:object[@"organization"]];
            }
            
            self.queryFinished = YES;
            [self reloadTableView];
        }
        else {
            //TODO: Handle Error
        }
    }];
}

-(void)switchToUser:(PFUser*)newUser {
    NSString *password = [UICKeyChainStore stringForKey:newUser.username service:@"com.gwt.tize"];
    if (!password || [password isEqualToString:@""]) {
        [self showPasswordAlertWithUsername:newUser.username];
    }
    else {
        [self loginWithUsername:newUser.username password:password];
    }
}

-(void)showPasswordAlertWithUsername:(NSString*)username {
    UIAlertController *passwordController = [UIAlertController alertControllerWithTitle:@"Enter Password" message:username preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *passwordTextField = passwordController.textFields[0];
        NSString *password = passwordTextField.text;
        
        [UICKeyChainStore setString:password forKey:username service:@"com.gwt.tize"];
        [self loginWithUsername:username password:password];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];
    
    [passwordController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [passwordController addAction:loginAction];
    [passwordController addAction:cancelAction];
    [self presentViewController:passwordController animated:YES completion:nil];
}

-(void)loginWithUsername:(NSString*)username password:(NSString*)password {
    [SVProgressHUD show];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (!error) {
            UIViewController *basePageController = [((GWTAppDelegate*)[[UIApplication sharedApplication] delegate]) setupMainView];
            [self presentViewController:basePageController animated:YES completion:nil];
            [SVProgressHUD dismiss];
        }
        else {
            [SVProgressHUD dismiss];
            //TODO: If error is invalid password
            [self showPasswordAlertWithUsername:username];
        }
    }];
}

@end
