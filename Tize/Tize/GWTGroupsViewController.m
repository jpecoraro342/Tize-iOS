//
//  GWTGroupsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTGroupsViewController.h"
#import "GWTInviteToGroupViewController.h"
#import <Parse/Parse.h>

@interface GWTGroupsViewController () <UITabBarDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *listOfGroups;
@property (nonatomic, strong) NSMutableArray *filteredListOfGroups;

@end

@implementation GWTGroupsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        self.listOfGroups = [NSMutableArray array];
        
        [self queryGroups];
        UITabBarItem *groups = self.tabBarItem;
        [groups setTitle:@"Groups"];
        [groups setImage:[UIImage imageNamed:@"groupstab.png"]];
    }
    return self;
}
    
-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = cancel;
    
    [self setSizeOfBottomBar:49];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *addGroup = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup)];
    self.rightBarButtonItem = addGroup;
}

#pragma mark - Table View

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.currentGroupsList count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"My Groups";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return self.currentGroupsList[indexPath.row][@"name"];
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self loadGroupInvite:[self.currentGroupsList objectAtIndex:indexPath.row]];
}

#pragma mark - Table View Edit

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *group = [self.currentGroupsList objectAtIndex:indexPath.row];
        [group deleteEventually];
        [self.currentGroupsList removeObjectAtIndex:indexPath.row];
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
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.listOfGroups count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                if (succeeded) {
                    [self loadGroupInvite:group];
                }
            }
        }];
    }
}

-(void)loadGroupInvite:(PFObject *)group {
    GWTInviteToGroupViewController *groupInvite = [[GWTInviteToGroupViewController alloc] initWithGroup:group];
    [self presentViewController:groupInvite animated:YES completion:nil];
}

#pragma mark - Search

-(void)updateFilteredListsWithString:(NSString*)searchString {
    self.filteredListOfGroups = [self.listOfGroups mutableCopy];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchString];
    if (searchString && ![searchString isEqualToString:@""]) {
        [self.filteredListOfGroups filterUsingPredicate:searchPredicate];
    }
}

-(NSMutableArray *)currentGroupsList {
    return [super searchIsActive] ? self.filteredListOfGroups : self.listOfGroups;
}


@end
