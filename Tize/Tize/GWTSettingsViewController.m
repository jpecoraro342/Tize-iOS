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
#import "GWTOrganizationListViewController.h"
#import "UICKeyChainStore.h"

@interface GWTSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GWTSettingsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:kNavBarColor];
    self.navigationItem.titleView = kNavBarTitleView;
    [self.navigationController.navigationBar setTintColor:kNavBarTintColor];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    self.navigationItem.rightBarButtonItem = done;
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        case 1:
        case 2:
        case 3:
        default:
            return 44;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 3;
        case 2:
            return 0;
        case 3:
            return 4;
        default:
            return 0;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    
    switch (section) {
        case 0:
            titleLabel.text = @"My Account";
            break;
        case 1:
            titleLabel.text = @"Notifications";
            break;
        case 2:
            titleLabel.text =  @"Contact";
            break;
        case 3:
            titleLabel.text = @"More Information";
    }
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"Username: %@", [[PFUser currentUser] username]];
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"Phone: %@", @"111-222-3333"];
                    break;
                case 2:
                    cell.textLabel.text = @"Logout";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    break;
                case 3:
                    cell.textLabel.text = @"Switch To Organization View";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"New Friend Requests";
                    cell.accessoryType = [[NSUserDefaults standardUserDefaults] boolForKey:@"newFriendRequestNotification"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 1:
                    cell.textLabel.text = @"Event Invites";
                    cell.accessoryType = [[NSUserDefaults standardUserDefaults] boolForKey:@"newEventInvitesNotification"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 2:
                    cell.textLabel.text = @"Events Upcoming";
                    cell.accessoryType = [[NSUserDefaults standardUserDefaults] boolForKey:@"upcomingEventsNotification"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                    default:
                        break;
            }
            break;
        case 3:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Tutorial";
                    break;
                case 1:
                    cell.textLabel.text = @"Terms of Use";
                    break;
                case 2:
                    cell.textLabel.text = @"Privacy Policy";
                    break;
                case 3:
                    cell.textLabel.text = @"Feedback";
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                case 1:
                    break;
                case 2:
                    [self logout];
                    break;
                case 3:
                    [self switchToOrganization];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            [self toggleNotification:indexPath];
            break;
        case 2:
            switch (indexPath.row) {
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    [self loadTutorial];
                    break;
                case 1:
                    [self loadTermsOfUse];
                    break;
                case 2:
                    [self loadPrivacyPolicy];
                    break;
                case 3:
                    [self loadFeedback];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark - Private Methods

-(void)toggleNotification:(NSIndexPath*)indexPath {
    NSInteger row = indexPath.row;
    switch (row) {
        case 0: {
            //toggle new friend requests
            BOOL selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"newFriendRequestNotification"];
            selected = !selected;
            [[NSUserDefaults standardUserDefaults] setBool:selected forKey:@"newFriendRequestNotification"];
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
        case 1: {
            //toggle eventInvites Notification
            BOOL selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"newEventInvitesNotification"];
            selected = !selected;
            [[NSUserDefaults standardUserDefaults] setBool:selected forKey:@"newEventInvitesNotification"];
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
        case 2: {
            //toggle upcoming events
            BOOL selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"upcomingEventsNotification"];
            selected = !selected;
            [[NSUserDefaults standardUserDefaults] setBool:selected forKey:@"upcomingEventsNotification"];
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
    }
}

-(void)switchToOrganization {
    [self.navigationController pushViewController:[[GWTOrganizationListViewController alloc] init] animated:YES];
}

-(void)loadTutorial {
    
}

-(void)loadTermsOfUse {
    
}

-(void)loadPrivacyPolicy {
    
}

-(void)loadFeedback {
    
}

-(void)logout {
    [PFUser logOut];
    [UICKeyChainStore removeItemForKey:@"com.currentuser.username" service:@"com.gwt.tize"];
    GWTLoginViewController *login = [[GWTLoginViewController alloc] init];
    
    [self presentViewController:login animated:YES completion:^{
        self.view.window.rootViewController = login;
    }];
}

-(void)doneEditing {
    //save the settings
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Settings VC"];
}

@end
