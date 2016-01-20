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
@property (nonatomic, strong) NSMutableArray* peopleImFollowingNotFollowingMe;

@property (nonatomic, strong) NSMutableArray* filteredListOfFriendsWhoAddedMe;
@property (nonatomic, strong) NSMutableArray* filteredListOfFriendsIveAdded;
@property (nonatomic, strong) NSMutableArray* filteredPeopleImFollowingNotFollowingMe;

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
            return [super searchIsActive] ? [self.filteredListOfFriendsWhoAddedMe count] : [self.listOfFriendsWhoAddedMe count];
        case 1:
            return [super searchIsActive] ? [self.filteredPeopleImFollowingNotFollowingMe count] : [self.peopleImFollowingNotFollowingMe count];
    }
    return 0;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"Tize Requests";
        }
        case 1: {
            return @"Friends Not Responded";
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
            if (indexPath.row < [self.listOfFriendsWhoAddedMe count]) {
                PFUser *userFollowing = [super searchIsActive] ? [self.filteredListOfFriendsWhoAddedMe objectAtIndex:indexPath.row] : [self.listOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
                cell.textLabel.text = [userFollowing username];
                cell.accessoryType = [self.friendsIveAdded objectForKey:[userFollowing objectId]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            break;
        }
        case 1: {
            if (indexPath.row < [self.peopleImFollowingNotFollowingMe count]) {
                PFUser *userImFollowing = [super searchIsActive] ? [self.peopleImFollowingNotFollowingMe objectAtIndex:indexPath.row] : [self.peopleImFollowingNotFollowingMe objectAtIndex:indexPath.row];
                cell.textLabel.text = [userImFollowing username];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        PFUser *friend = [super searchIsActive] ? [self.filteredListOfFriendsWhoAddedMe objectAtIndex:indexPath.row] : [self.listOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
        if ([self.friendsIveAdded objectForKey:[friend objectId]]) {
            [self removeFriendAtIndexPath:indexPath];
        }
        else {
            [self addFriendAtIndexPath:indexPath];
        }
    }
}

#pragma mark - SearchTableVC

-(void)updateFilteredListsWithString:(NSString*)searchString {
    self.filteredListOfFriendsIveAdded = [self filterList:self.listOfFriendsIveAdded withSearchString:searchString];
    self.filteredListOfFriendsWhoAddedMe = [self filterList:self.listOfFriendsWhoAddedMe withSearchString:searchString];
    self.filteredPeopleImFollowingNotFollowingMe = [self filterList:self.peopleImFollowingNotFollowingMe withSearchString:searchString];
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
            [self updateMeFollowingNotMe];
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
            [self updateMeFollowingNotMe];
            [self.tableView reloadData];
        }
    }];
}

-(void)updateMeFollowingNotMe {
    self.peopleImFollowingNotFollowingMe = [[NSMutableArray alloc] init];
    for (PFUser *friendsFollowing in self.listOfFriendsIveAdded) {
        if (![self.friendsWhoAddedMe objectForKey:friendsFollowing.objectId]) {
            [self.peopleImFollowingNotFollowingMe addObject:friendsFollowing];
        }
    }
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
    
    PFUser *user = [super searchIsActive] ? [self.filteredListOfFriendsWhoAddedMe objectAtIndex:indexPath.row] : [self.listOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
    [self startFollowingUser:user];
}

-(void)removeFriendAtIndexPath:(NSIndexPath*) indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    PFUser *user = [super searchIsActive] ? [self.filteredListOfFriendsWhoAddedMe objectAtIndex:indexPath.row] : [self.listOfFriendsWhoAddedMe objectAtIndex:indexPath.row];
    [self.friendsIveAdded removeObjectForKey:[user objectId]];
    //TODO:Write the code to remove a friend
}

-(void)startFollowingUser:(PFUser*)user {
    PFObject *following = [PFObject objectWithClassName:@"Following"];
    following[@"user"] = [[PFUser currentUser] objectId];
    following[@"following"] = [user objectId];
    [following saveEventually];
    
    [self.friendsIveAdded setObject:user forKey:[user objectId]];
    [self.listOfFriendsIveAdded insertObject:user atIndex:0];
    [self updateMeFollowingNotMe];
    [super reloadTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"List of Friends VC"];
}

@end
