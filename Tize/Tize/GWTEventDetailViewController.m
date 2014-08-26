//
//  GWTEventDetailViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEventDetailViewController.h"
#import "GWTEventsViewController.h"

@interface GWTEventDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIBarPositioningDelegate>

@property (nonatomic, strong) UILabel *eventNameLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *startDateLabel;
@property (nonatomic, strong) UILabel *endDateLabel;
@property (nonatomic, strong) UITextView *aboutTextView;

@property (nonatomic, strong) UILabel *numAttendingLabel;
@property (nonatomic, strong) UILabel *numMaybeAttendingLabel;
@property (nonatomic, strong) UILabel *numDeclinedLabel;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger usersAttending;
@property (assign, nonatomic) NSInteger usersMaybeAttending;
@property (assign, nonatomic) NSInteger usersNotAttending;

@property (strong, nonatomic) UILabel *attendingLabel;
@property (strong, nonatomic) UILabel *maybeAttendingLabel;
@property (strong, nonatomic) UILabel *notAttendingLabel;

@property (strong, nonatomic) UIButton *attendingButton;
@property (strong, nonatomic) UIButton *maybeAttendingButton;
@property (strong, nonatomic) UIButton *notAttendingButton;

@end

@implementation GWTEventDetailViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBarTintColor:kNavBarColor];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.titleView = kNavBarTitleView;
    [self.navigationBar setItems:@[navItem]];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

-(void)reloadWithEvent:(GWTEvent *)event {
    self.event = event;
    [self updateFields];
    [self queryAttendingStatus];
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                    return 44;
                case 3:
                    return 120;
                case 4:
                    return 60;
            }
        }
        case 1:
        case 2:
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
    return 3;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    switch (section) {
        case 0: {
            titleLabel.text = self.event.eventName;
            _eventNameLabel = titleLabel;
            break;
        }
        case 1:
            titleLabel.text = @"Guests";
            break;
        case 2:
            titleLabel.text =  @"";
            break;
    }
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 5;
        case 1:
            return 3;
        case 2:
            return 1;
        default:
            return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    
    switch (indexPath.section) {
        case 0: {
            return [self cellForRow:indexPath.row];
        }
        case 1: {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, 200, 44)];
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [icon setContentMode:UIViewContentModeScaleAspectFit];
            switch (indexPath.row) {
                case 0:
                    self.attendingLabel = label;
                    [icon setImage:[UIImage imageNamed:@"attendingIcon.png"]];
                    break;
                case 1:
                    self.maybeAttendingLabel = label;
                    [icon setImage:[UIImage imageNamed:@"maybeIcon.png"]];
                    break;
                case 2:
                    self.notAttendingLabel = label;
                    [icon setImage:[UIImage imageNamed:@"notAttendingIcon.png"]];
                    break;
            }
            [self updateAttendingLabels];
            [cell addSubview:label];
            [cell addSubview:icon];
            break;
        }
        case 2: {
            break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *)cellForRow:(NSInteger)row {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 200, 28)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 200, 10)];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    switch (row) {
        case 0: {
            [titleLabel setText:@"Location:"];
            _locationLabel = infoLabel;
            [infoLabel setText:self.event.locationName];
            break;
        }
        case 1: {
            [titleLabel setText:@"Start Time:"];
            _startDateLabel = infoLabel;
            [infoLabel setText:[self.event startTime]];
            break;
        }
        case 2: {
            [titleLabel setText:@"End Time:"];
            _endDateLabel = infoLabel;
            [infoLabel setText:[self.event endTime]];
            break;
        }
        case 3: {
            [titleLabel setText:@"About:"];
            _aboutTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 14, self.tableView.frame.size.width-20, 100)];
            [_aboutTextView setText:[self.event eventDetails]];
            _aboutTextView.editable = NO;
            _aboutTextView.scrollEnabled = NO;
            [cell addSubview:titleLabel];
            [cell addSubview:_aboutTextView];
            return cell;
        }
        case 4: {
            CGFloat width = self.tableView.frame.size.width/3;
            _attendingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 45)];
            [self.attendingButton setBackgroundImage:[UIImage imageNamed:@"attendingButton.png"] forState:UIControlStateNormal];
            [self.attendingButton addTarget:self action:@selector(setAttendingStatus:) forControlEvents:UIControlEventTouchUpInside];
            
            _maybeAttendingButton = [[UIButton alloc] initWithFrame:CGRectMake(width, 0, width, 45)];
            [self.maybeAttendingButton setBackgroundImage:[UIImage imageNamed:@"maybeAttendingButton.png"] forState:UIControlStateNormal];
            [self.maybeAttendingButton addTarget:self action:@selector(setAttendingStatus:) forControlEvents:UIControlEventTouchUpInside];
            
            _notAttendingButton = [[UIButton alloc] initWithFrame:CGRectMake(width*2, 0, width, 45)];
            [self.notAttendingButton setBackgroundImage:[UIImage imageNamed:@"notAttendingButton.png"] forState:UIControlStateNormal];
            [self.notAttendingButton addTarget:self action:@selector(setAttendingStatus:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:self.attendingButton];
            [cell addSubview:self.maybeAttendingButton];
            [cell addSubview:self.notAttendingButton];
        }
    }
    
    [cell addSubview:titleLabel];
    [cell addSubview:infoLabel];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Other

-(void)updateFields {
    [self.eventNameLabel setText:[self.event eventName]];
    [self.aboutTextView setText:[self.event eventDetails]];
    [self.locationLabel setText:[self.event locationName]];
    [self.startDateLabel setText:[self.event startTime]];
    [self.endDateLabel setText:[self.event startTime]];
}

-(void)updateAttendingLabels {
    [self.attendingLabel setText:[NSString stringWithFormat:@"Attending (%zd)", self.usersAttending]];
    [self.maybeAttendingLabel setText:[NSString stringWithFormat:@"Maybe (%zd)", self.usersMaybeAttending]];
    [self.notAttendingLabel setText:[NSString stringWithFormat:@"Declined (%zd)", self.usersNotAttending]];
}

-(void)queryAttendingStatus {
    //query my attending status
    PFQuery *attendingStatus = [PFQuery queryWithClassName:@"EventUsers"];
    [attendingStatus whereKey:@"eventID" equalTo:self.event.objectId];
    [attendingStatus whereKey:@"userID" equalTo:[[PFUser currentUser] objectId]];
    [attendingStatus getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError* error) {
        if (!error) {
            self.currentAttendingStatus = object;
            
        }
        else {
            self.currentAttendingStatus = [PFObject objectWithClassName:@"EventUsers"];
            self.currentAttendingStatus[@"userID"] = [[PFUser currentUser] objectId];
            self.currentAttendingStatus[@"eventID"] = self.event.objectId;
        }
    }];
    
    //get all attending
    [self countUsersWithAttendingStatus:0];
    //get all maube attending
    [self countUsersWithAttendingStatus:1];
    //get all not attending
    [self countUsersWithAttendingStatus:2];
}

-(void)setAttendingStatus:(UIButton*)sender {
    NSInteger current = [self.currentAttendingStatus[@"attendingStatus"] integerValue];
    
    if ([sender isEqual:self.attendingButton]) {
        self.currentAttendingStatus[@"attendingStatus"] = @(0);
        self.usersAttending++;
    }
    else if ([sender isEqual:self.maybeAttendingButton]) {
        self.currentAttendingStatus[@"attendingStatus"] = @(1);
        self.usersMaybeAttending++;
    }
    else if ([sender isEqual:self.notAttendingButton]) {
        self.currentAttendingStatus[@"attendingStatus"] = @(2);
        self.usersNotAttending++;
    }
    [self.currentAttendingStatus saveInBackground];
    
    switch (current) {
        case 0: {
            self.usersAttending--;
            break;
        }
        case 1: {
            self.usersMaybeAttending--;
            break;
        }
        case 2: {
            self.usersNotAttending--;
            break;
        }
    }
    
    [self updateAttendingLabels];
}

-(void)countUsersWithAttendingStatus:(NSInteger)attending {
    PFQuery *attendingStatus = [PFQuery queryWithClassName:@"EventUsers"];
    [attendingStatus whereKey:@"eventID" equalTo:self.event.objectId];
    [attendingStatus whereKey:@"attendingStatus" equalTo:[NSNumber numberWithInteger:attending]];
    
    PFQuery *users = [PFUser query];
    [users whereKey:@"objectId" matchesKey:@"userID" inQuery:attendingStatus];
    [users countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            switch (attending) {
                case 0: {
                    self.usersAttending = count;
                    break;
                }
                case 1: {
                    self.usersMaybeAttending = count;
                    break;
                }
                case 2: {
                    self.usersNotAttending = count;
                    break;
                }
            }
            [self updateAttendingLabels];
        }
        else {
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
