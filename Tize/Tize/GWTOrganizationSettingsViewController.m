//
//  GWTOrganizationSettingsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTOrganizationSettingsViewController.h"
#import "GWTAppDelegate.h"
#import "UICKeyChainStore.h"
#import "SVProgressHUD.h"
#import "Parse.h"

@interface GWTOrganizationSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString* switchedUser;

@end

@implementation GWTOrganizationSettingsViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"GWTSettingsViewController" bundle:nil];
    if (self) {
        self.switchedUser = [UICKeyChainStore stringForKey:@"com.currentuser.username" service:@"com.gwt.tize"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - TableView Overrides

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.switchedUser ? 4 : 3;
    }
    return [super tableView:self.tableView numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 3) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        cell.textLabel.text = [NSString stringWithFormat:@"Switch To: %@", self.switchedUser];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    else {
        return [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Parse User Switching

-(void)switchToOrganization {
    [self switchToSavedUser];
}

-(void)switchToSavedUser {
    NSString *currentStoredUser = [UICKeyChainStore stringForKey:@"com.currentuser.username" service:@"com.gwt.tize"];
    NSString *password = [UICKeyChainStore stringForKey:currentStoredUser service:@"com.gwt.tize"];
    
    if (!password || [password isEqualToString:@""]) {
        [self showPasswordAlertWithUsername:currentStoredUser];
    }
    else {
        [self loginWithUsername:currentStoredUser password:password];
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
