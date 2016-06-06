//
//  GWTFriendsTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeFriendsTableViewController.h"
#import "GWTSettingsViewController.h"
#import "GWTEventsViewController.h"
#import "UIImage+Color.h"

@interface GWTTizeFriendsTableViewController () <UITabBarDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) NSMutableArray* listOfFriendsWhoAddedMe;
@property (nonatomic, strong) NSMutableArray* listOfFriendsIveAdded;

@property (nonatomic, strong) NSMutableArray* filteredListOfFriendsWhoAddedMe;
@property (nonatomic, strong) NSMutableArray* filteredListOfFriendsIveAdded;

@property (nonatomic, strong) NSMutableDictionary* friendsWhoAddedMe;
@property (nonatomic, strong) NSMutableDictionary* friendsIveAdded;

@end

@implementation GWTTizeFriendsTableViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        [self queryAll];
        UITabBarItem *tize = self.tabBarItem;
        [tize setTitle:@"My Tize"];
        [tize setImage:[UIImage imageNamed:@"logo_tab_bar.png"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = cancel;
    
    UIBarButtonItem *addFriend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(startFollowing)];
    self.rightBarButtonItem = addFriend;
    
    [self setSizeOfBottomBar:49];
}

#pragma mark - Tableview delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.getListOfFriendsIveAdded count];
        case 1:
            return [self.getListOfFriendsWhoAddedMe count];
    }
    return 0;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"Following";
        }
        case 1: {
            return @"Followers";
        }
    }
    
    return @"";
}

-(NSString *)titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

-(NSString *)subtitleForCellAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row < [self.listOfFriendsIveAdded count]) {
                PFUser *userFollowing = [self.getListOfFriendsIveAdded objectAtIndex:indexPath.row];
                cell.textLabel.text = [userFollowing username];
                cell.accessoryType = [self.friendsWhoAddedMe objectForKey:[userFollowing objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            break;
        }
        case 1: {
            if (indexPath.row < [self.listOfFriendsWhoAddedMe count]) {
                PFUser *userImFollowing = [self.getListOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
                cell.textLabel.text = [userImFollowing username];
                cell.accessoryType = [self.friendsIveAdded objectForKey:[userImFollowing objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // TODO: View the users "profile", their upcoming events, or something of the sort
}

-(NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *rowUser = indexPath.section == 0 ? [self.getListOfFriendsIveAdded objectAtIndex:indexPath.row] : [self.getListOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
    
    if ([self.friendsIveAdded objectForKey:[rowUser objectId]]) {
        return @[[self stopFollowingUserRowAction: rowUser]];
    }
    
    return @[[self followUserRowAction: rowUser]];
}

-(UITableViewRowAction*)followUserRowAction:(PFUser *)user {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Follow" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self confirmFollowUser:user];
    }];
    
    rowAction.backgroundColor = kGreenColor;
    return rowAction;
}

-(UITableViewRowAction*)stopFollowingUserRowAction:(PFUser *)user {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Unfollow" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self confirmStopFollowingUser:user];
    }];
    
    rowAction.backgroundColor = kRedColor;
    return rowAction;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

#pragma mark - SearchTableVC

-(void)updateFilteredListsWithString:(NSString*)searchString {
    self.filteredListOfFriendsIveAdded = [self filterList:self.listOfFriendsIveAdded withSearchString:searchString];
    self.filteredListOfFriendsWhoAddedMe = [self filterList:self.listOfFriendsWhoAddedMe withSearchString:searchString];
}

-(NSMutableArray*)filterList:(NSArray*)list withSearchString:(NSString*)searchString {
    NSMutableArray *filteredList = [list mutableCopy];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username contains[cd] %@", searchString];
    if (searchString && ![searchString isEqualToString:@""]) {
        [filteredList filterUsingPredicate:searchPredicate];
    }
    
    return filteredList;
}

#pragma mark query

-(void)queryAll {
    [self queryMyFollowing];
    [self queryFollingMe];
}

-(void)queryFollingMe {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersFollowingMe = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"following" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersFollowingMe whereKey:@"objectId" matchesKey:@"user" inQuery:getAllFollowingEvents];
    [getAllUsersFollowingMe findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        self.listOfFriendsWhoAddedMe = [[NSMutableArray alloc] init];
        self.friendsWhoAddedMe = [[NSMutableDictionary alloc] init];
        if(!error) {
            for (PFUser *object in objects) {
                [self.listOfFriendsWhoAddedMe addObject:object];
                [self.friendsWhoAddedMe setObject:object forKey:[object objectId]];
            }
            [self.tableView reloadData];
        }
    }];
}

-(void)queryMyFollowing {
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersWeAreFollowing = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersWeAreFollowing whereKey:@"objectId" matchesKey:@"following" inQuery:getAllFollowingEvents];
    [getAllUsersWeAreFollowing findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        self.friendsIveAdded = [[NSMutableDictionary alloc] init];
        self.listOfFriendsIveAdded = [[NSMutableArray alloc] init];
        if(!error) {
            for (PFUser *object in objects) {
                [self.listOfFriendsIveAdded addObject:object];
                [self.friendsIveAdded setObject:object forKey:[object objectId]];
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark Other

-(void)startFollowing {
    UIAlertController *startFollowing = [UIAlertController alertControllerWithTitle:@"Follow Friend" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *followAction = [UIAlertAction actionWithTitle:@"Follow" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *usernameField = startFollowing.textFields[0];
        NSString *username = usernameField.text;
        
        [self followUserWithUsername:username];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];
    
    [startFollowing addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"username";
        if (self.searchBarText != nil && ![self.searchBarText isEqualToString:@""]) {
            textField.text = self.searchBarText;
        }
    }];
    
    [startFollowing addAction:followAction];
    [startFollowing addAction:cancelAction];
    [self presentViewController:startFollowing animated:YES completion:nil];
}

-(void)confirmFollowUser:(PFUser*)user {
    UIAlertController *startFollowing = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Follow %@", user.username] message:[NSString stringWithFormat:@"Are you sure you want to start following %@?", user.username] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *followAction = [UIAlertAction actionWithTitle:@"Follow" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self followUserWithUsername:user.username];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];

    [startFollowing addAction:followAction];
    [startFollowing addAction:cancelAction];
    [self presentViewController:startFollowing animated:YES completion:nil];
}

-(void)confirmStopFollowingUser:(PFUser*)user {
    UIAlertController *startFollowing = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Unfollow %@", user.username] message:[NSString stringWithFormat:@"Are you sure you want to stop following %@?", user.username] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *followAction = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self stopFollowingUser:user];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];
    
    [startFollowing addAction:followAction];
    [startFollowing addAction:cancelAction];
    [self presentViewController:startFollowing animated:YES completion:nil];
}
                                    

-(void)followUserWithUsername:(NSString*)username {
    PFQuery *userForUsername = [PFUser query];
    [userForUsername whereKey:@"username" equalTo:username];
    [userForUsername getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (!error) {
            if (!user) {
                [[[UIAlertView alloc] initWithTitle:@"Unable to add user" message:@"user not found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            else {
                [self startFollowingUser:(PFUser*)user];
            }
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Unable to add user" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

-(void)addFriendAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFUser *user = [self.getListOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
    [self startFollowingUser:user];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [self.getListOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
    [self stopFollowingUser:user];
}

-(void)stopFollowingUser:(PFUser *)user {
    PFQuery *getFollowEvents = [PFQuery queryWithClassName:@"Following"];
    
    [getFollowEvents whereKey:@"user" equalTo:[[PFUser currentUser] objectId]];
    [getFollowEvents whereKey:@"following" equalTo:user.objectId];
    [getFollowEvents findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    [self.tableView reloadData];
                }
                else {
                    NSLog(@"Could not delete following events");
                }
            }];
        }
        else {
            NSLog(@"Unable to stop following users");
        }
    }];
    
    [self.friendsIveAdded removeObjectForKey:[user objectId]];
    [self.listOfFriendsIveAdded removeObject:user];
    [super reloadTableView];
}

-(void)startFollowingUser:(PFUser*)user {
    PFObject *following = [PFObject objectWithClassName:@"Following"];
    following[@"user"] = [[PFUser currentUser] objectId];
    following[@"following"] = [user objectId];
    [following saveEventually];
    
    [self.friendsIveAdded setObject:user forKey:[user objectId]];
    [self.listOfFriendsIveAdded insertObject:user atIndex:0];
    [super reloadTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"List of Friends VC"];
}

-(NSMutableArray*)getListOfFriendsIveAdded {
    return [super searchIsActive] ? self.filteredListOfFriendsIveAdded : self.listOfFriendsIveAdded;
}

-(NSMutableArray*)getListOfFriendsWhoAddedMe {
    return [super searchIsActive] ? self.filteredListOfFriendsWhoAddedMe : self.listOfFriendsWhoAddedMe;
}

@end
