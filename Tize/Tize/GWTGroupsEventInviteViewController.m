//
//  GWTGroupsEventInviteViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 1/22/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTGroupsEventInviteViewController.h"
#import "GWTInviteToGroupViewController.h"
#import <Parse/Parse.h>

@interface GWTGroupsEventInviteViewController () <UITabBarDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *listOfGroups;

@end

@implementation GWTGroupsEventInviteViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self queryGroups];
        UITabBarItem *groups = self.tabBarItem;
        [groups setTitle:@"Select Groups to Invite"];
        [groups setImage:[UIImage imageNamed:@"groupstab.png"]];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = cancel;
    
    UIBarButtonItem *invite = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteSelected)];
    self.rightBarButtonItem = invite;
    
    [self setSizeOfBottomBar:49];
}

#pragma mark - Table View

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.listOfGroups count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"Invite Groups";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return self.listOfGroups[indexPath.row][@"name"];
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
}

#pragma mark - Table View Edit

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *group = [self.listOfGroups objectAtIndex:indexPath.row];
        [group deleteEventually];
        [self.listOfGroups removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -

-(void)addGroup {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create Group" message:@"Enter the group name: " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0]  setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [alertView show];
}

-(void)queryGroups {
    PFQuery *getAllMyGroups = [PFQuery queryWithClassName:@"Groups"];
    
    [getAllMyGroups whereKey:@"owner" equalTo:[PFUser currentUser]];
    [getAllMyGroups findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            self.listOfGroups = [[NSMutableArray alloc] init];
            for (PFUser *object in objects) {
                [self.listOfGroups addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Alertview

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSString* text = [alertView textFieldAtIndex:0].text;
    
    //if the text length is greater than 0, return yes, otherwise return no
    return text.length > 0 ? YES : NO;
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *groupName = textField.text;
        PFObject *group = [PFObject objectWithClassName:@"Groups"];
        group[@"name"] = groupName;
        group[@"owner"] = [PFUser currentUser];
        [self.listOfGroups addObject:group];
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                if (succeeded) {
                    //[self loadGroupInvite:group];
                }
            }
        }];
    }
}

@end