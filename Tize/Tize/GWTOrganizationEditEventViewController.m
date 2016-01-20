//
//  GWTOrganizationEditEventViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 3/18/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTOrganizationEditEventViewController.h"
#import "GWTInviteFriendsToEventCommand.h"

@interface GWTOrganizationEditEventViewController ()

@property (strong, nonatomic) UILabel *eventTypeLabel;
@property (strong, nonatomic) UITextField *eventNameTextField;
@property (strong, nonatomic) UITextView *eventDescriptionTextView;
@property (strong, nonatomic) UITextField *eventLocationTextField;
@property (strong, nonatomic) UILabel *eventStartTimeLabel;
@property (strong, nonatomic) UILabel *eventEndTimeLabel;
@property (strong, nonatomic) UIButton *createEventButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIDatePicker* startDatePicker;
@property (strong, nonatomic) UIDatePicker* endDatePicker;

@property (assign, nonatomic) BOOL startDateShouldShow;
@property (assign, nonatomic) BOOL endDateShouldShow;

@property (assign, nonatomic) BOOL isEdit;
@property (assign, nonatomic) BOOL shouldSaveChanges;

@property (nonatomic, strong) NSArray *peopleToInvite;

@property (nonatomic, strong) UICollectionView *iconCollectionView;

@property (nonatomic, strong) NSArray *iconArray;

@property (nonatomic, assign) BOOL isPublic;

@property (nonatomic, strong) UISwitch *isPublicSwitch;

@end

@implementation GWTOrganizationEditEventViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"GWTEditEventViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(void)reloadWithEvent:(GWTEvent *)event {
    [super reloadWithEvent:event];
    self.isPublic = event.publicEvent;
}

#pragma mark Table View

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 8:
                return 44;
            case 9:
                return self.isPublic ? 0 : 55;
            default:
                return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
        }
    }
    
    return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 10;
        case 1:
            return 1;
    }
    return 0;
}

//Add the organization name in the center if index is 0.
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [super tableView:self.tableView viewForHeaderInSection:section];
    
    if (section == 0) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, CGRectGetHeight(headerView.frame))];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
        [nameLabel setText:[PFUser currentUser].username];
        
        [headerView addSubview:nameLabel];
    }
    
    return headerView;
}

//Insert the cell for is public event in between the last 2
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || indexPath.row < 8) {
        return [super tableView:self.tableView cellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.row == 9) {
        return [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0]];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cell.frame.size.width - 20, 44)];
    titleLabel.text = @"Public Event: ";

    self.isPublicSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width - 60, (44-31)/2, 51, 31)];
    self.isPublicSwitch.onTintColor = kGreenColor;
    
    [self.isPublicSwitch setOn:self.isPublic animated:NO];
    [self.isPublicSwitch addTarget:self action:@selector(changePublicValue) forControlEvents:UIControlEventValueChanged];
    
    [cell addSubview:titleLabel];
    [cell addSubview:self.isPublicSwitch];
    return cell;
}

//The Invite Friends Row Needs to Be shifted
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 9) {
        return [super tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0]];
    }
    else if (indexPath.row == 8) {
        return;
    }
    else {
        return [super tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

//Add the on/off switch for public/private
/*
-(void)updateFields {
   
}*/

-(void)changePublicValue {
    self.isPublic = self.isPublicSwitch.isOn;
    [self.event setPublicEvent:self.isPublic];
    [self.view endEditing:YES];
    [super updateTableView];
}

//Add public/private
-(void)updateEvent {
    [super updateEvent];
    [self.event setPublicEvent:self.isPublic];
}

-(void)sendOutInvites:(GWTEvent*)event {
    if (!self.isPublic) {
        return [super sendOutInvites:event];
    }
    
    /*[self.friendInvites removeAllFriends];
    
    PFQuery *getAllFollowingEvents = [PFQuery queryWithClassName:@"Following"];
    PFQuery *getAllUsersFollowingMe = [PFUser query];
    
    [getAllFollowingEvents whereKey:@"following" equalTo:[[PFUser currentUser] objectId]];
    [getAllUsersFollowingMe whereKey:@"objectId" matchesKey:@"user" inQuery:getAllFollowingEvents];
    [getAllUsersFollowingMe findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFUser *object in objects) {
                [self.friendInvites addFriend:object];
            }
            [self.friendInvites execute];
        }
    }]; */
}

@end
