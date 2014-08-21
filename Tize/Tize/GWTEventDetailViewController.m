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
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 44)];
            switch (indexPath.row) {
                case 0:
                    [label setText:@"Attending"];
                    break;
                case 1:
                    [label setText:@"Maybe"];
                    break;
                case 2:
                    [label setText:@"Declined"];
                    break;
            }
            [cell addSubview:label];
            break;
        }
        case 2: {
            break;
        }
    }
    return cell;
}

-(UITableViewCell *)cellForRow:(NSInteger)row {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
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
            [infoLabel setText:[self.event timeString]];
            break;
        }
        case 2: {
            [titleLabel setText:@"End Time:"];
            _endDateLabel = infoLabel;
            [infoLabel setText:[self.event timeString]];
            break;
        }
        case 3: {
            [titleLabel setText:@"About:"];
            _aboutTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 14, self.tableView.frame.size.width-20, 108)];
            [_aboutTextView setText:[self.event eventDetails]];
            _aboutTextView.editable = NO;
            _aboutTextView.scrollEnabled = NO;
            [cell addSubview:titleLabel];
            [cell addSubview:_aboutTextView];
            return cell;
        }
        case 4: {
            CGFloat width = self.tableView.frame.size.width/3;
            UIButton *attending = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 45)];
            [attending setBackgroundImage:[UIImage imageNamed:@"attendingButton.png"] forState:UIControlStateNormal];
            UIButton *maybe = [[UIButton alloc] initWithFrame:CGRectMake(width, 0, width, 45)];
            [maybe setBackgroundImage:[UIImage imageNamed:@"maybeAttendingButton.png"] forState:UIControlStateNormal];
            UIButton *not = [[UIButton alloc] initWithFrame:CGRectMake(width*2, 0, width, 45)];
            [not setBackgroundImage:[UIImage imageNamed:@"notAttendingButton.png"] forState:UIControlStateNormal];
            
            [cell addSubview:attending];
            [cell addSubview:maybe];
            [cell addSubview:not];
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
    [self.startDateLabel setText:[self.event timeString]];
    [self.endDateLabel setText:[self.event timeString]];
}

-(void)queryAttendingStatus {
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
}

#pragma mark navigation

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentAttendingStatus saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
