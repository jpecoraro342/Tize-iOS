//
//  GWTManageOrganizationAdminsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 5/31/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTManageOrganizationAdminsViewController.h"
#import "SVProgressHUD.h"
#import <Parse/Parse.h>

@interface GWTManageOrganizationAdminsViewController ()

@property(nonatomic, strong) NSMutableArray *listOfAdmins;
@property (nonatomic, assign) BOOL queryFinished;

@end

@implementation GWTManageOrganizationAdminsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self queryAdmins];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = backButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddAdminAlert)];
    self.rightBarButtonItem = addButton;
}

#pragma mark - TizeTableViewOverrides

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfAdmins count] == 0 && self.listOfAdmins ? 1 : [self.listOfAdmins count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"Admins";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    if ([self.listOfAdmins count] == 0 && self.queryFinished) {
        return @"Could not find any Admins";
    }
    else {
        return [[self.listOfAdmins objectAtIndex:indexPath.row] username];
    }
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

-(void)selectedItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Handle Selection - What do we do?
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeAdminAtIndex:indexPath.row];
    }
}

//TODO: Editing stuff

#pragma mark - Query

-(void)queryAdmins {
    PFQuery *getAllAdminUsers = [PFQuery queryWithClassName:@"OrganizationAdmins"];
    [getAllAdminUsers whereKey:@"organization" equalTo:[PFUser currentUser]];
    [getAllAdminUsers includeKey:@"admin"];
 
    [getAllAdminUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listOfAdmins = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            
            for (PFObject *object in objects) {
                [self.listOfAdmins addObject:object[@"admin"]];
            }
            [self.tableView reloadData];
        }
        else {
            //TODO: Handle Error
        }
    }];
}

#pragma mark - Editing

-(void)removeAdminAtIndex:(NSInteger)row {
    [SVProgressHUD show];
    
    PFQuery *removeOrgAdmin = [PFQuery queryWithClassName:@"OrganizationAdmins"];
    [removeOrgAdmin whereKey:@"admin" equalTo:[self.listOfAdmins objectAtIndex:row]];
    [removeOrgAdmin whereKey:@"organization" equalTo:[PFUser currentUser]];
    
    [removeOrgAdmin getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            [object deleteEventually];
            [SVProgressHUD showSuccessWithStatus:@"User removed as admin"];
            [self.listOfAdmins removeObjectAtIndex:row];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            NSLog(@"Could not remove %@ as an admin", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Unable to remove %@ as an admin: %@", [[self.listOfAdmins objectAtIndex:row] username], error.localizedDescription]];
        }
    }];
}

-(void)showAddAdminAlert {
    UIAlertController *addAdminController = [UIAlertController alertControllerWithTitle:@"Add Admin" message:@"Please enter the username for the admin you would like to add" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *addAdminAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *adminUsernameTextfield = addAdminController.textFields[0];
        NSString *username = adminUsernameTextfield.text;
        
        NSError *validationError = [self validateValidAdminUsername:username];
        
        if (!validationError) {
            [self addAdminWithUsername:username];
        }
        else {
            [self showAlertWithError:validationError];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];
    
    [addAdminController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
    }];
    
    [addAdminController addAction:addAdminAction];
    [addAdminController addAction:cancelAction];
    [self presentViewController:addAdminController animated:YES completion:nil];
}

-(NSError*)validateValidAdminUsername:(NSString*)username {
    NSError __block *error;
    
    // Verify the user has not already been added
    [self.listOfAdmins enumerateObjectsUsingBlock:^(PFUser *admin, NSUInteger index, BOOL *stop) {
        if ([admin.username isEqualToString:username]) {
            error = [NSError errorWithDomain:@"com.gwt.tize" code:0 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"%@ is already an admin", username] }];
            *stop = YES;
        }
    }];
    
    // TODO: Check if the username exists server side at all
    
    return error;
}

-(void)addAdminWithUsername:(NSString*)username {
    [SVProgressHUD showWithStatus:@"Attempting to Add User as Admin"];
    
    PFQuery *getUser = [PFUser query];
    [getUser whereKey:@"username" equalTo:username];
    
    [getUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFObject *orgAdmin = [PFObject objectWithClassName:@"OrganizationAdmins" dictionary:@{ @"organization" : [PFUser currentUser], @"admin" : object }];
            [orgAdmin saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"Added"];
                    [self.listOfAdmins addObject:object];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.listOfAdmins count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else {
                    NSLog(@"Could not add %@ as an admin: %@", username, error.localizedDescription);
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Unable to Add User As Admin: %@", error.localizedDescription]];
                }
            }];
        }
        else {
            NSString *errorMessage = error.code == kPFErrorObjectNotFound ? @"user not found" : error.localizedDescription;
            NSLog(@"Could not add %@ as an admin", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Unable to add %@ as an admin: %@", username, errorMessage]];
        }
    }];
}

-(void)showAlertWithError:(NSError*)error {
    [[[UIAlertView alloc] initWithTitle:@"Unable to add admin" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
