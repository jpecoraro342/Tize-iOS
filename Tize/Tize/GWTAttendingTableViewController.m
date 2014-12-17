//
//  GWTAttendingTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/26/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTAttendingTableViewController.h"
#import "GWTEventsViewController.h"
#import "GWTEvent.h"

@interface GWTAttendingTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation GWTAttendingTableViewController

-(void)reloadWithEvent:(GWTEvent *)event {
    self.event = event;
    self.titleLabel.text = self.event.eventName;
    [self initArrays];
    [self loadTableData];
    [self setNavItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavItems];
    [self.navigationBar setBarTintColor:kNavBarColor];
    [self.navigationBar setTintColor:kNavBarTintColor];
    [self.navigationBar setTintColor:kNavBarTintColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

-(void)setNavItems {
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.event.eventName];
    navItem.titleView = kNavBarTitleView;
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setTitleTextAttributes:kNavBarTitleDictionary];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark table view delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    }
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
        case 1:
            return [self.listOfAttending count];
        case 2:
            return [self.listOfMaybeAttending count];
        case 3:
            return [self.listOfNotAttending count];
        case 4:
            return [self.listOfNotResponded count];
        default:
            return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    PFUser *user;
    
    if (indexPath.section == 1) {
        if (indexPath.row < [self.listOfAttending count]) {
            user = [self.listOfAttending objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row < [self.listOfMaybeAttending count]) {
            user = [self.listOfMaybeAttending objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 3) {
        if (indexPath.row < [self.listOfNotAttending count]) {
            user = [self.listOfNotAttending objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 4) {
        if (indexPath.row < [self.listOfNotResponded count]) {
            user = [self.listOfNotResponded objectAtIndex:indexPath.row];
        }
    }
    
    cell.textLabel.text = [user username] ?: @"";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSInteger height = 38;
    if (section == 0) {
        height = 40;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, height)];
    [titleLabel setTextColor:kOffWhiteColor];
    
    switch (section) {
        case 0:
            titleLabel.text = self.event.eventName;
            [titleLabel setFont:[UIFont systemFontOfSize:20]];
            [titleLabel setTextColor:kWhiteColor];
            self.titleLabel = titleLabel;
            [headerView setBackgroundColor:[UIColor lightGrayColor]];
            break;
        case 1:
            titleLabel.text = @"Attending";
            [headerView setBackgroundColor:kGreenColor];
            break;
        case 2:
            titleLabel.text = @"Maybe Attending";
            [headerView setBackgroundColor:kLightOrangeColor];
            break;
        case 3:
            titleLabel.text = @"Not Attending";
            [headerView setBackgroundColor:kRedColor];
            break;
        case 4:
            titleLabel.text = @"Not Responded";
            [headerView setBackgroundColor:[UIColor lightGrayColor]];
            break;
    }
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
    [borderView setBackgroundColor:kBorderColor];
    
    [headerView addSubview:titleLabel];
    [headerView addSubview:borderView];
    return headerView;
}

#pragma mark queries
//0 is attending, 1 is maybe, 2 is not attending, 3 is not responded

-(void)initArrays {
    _listOfAttending = [[NSMutableArray alloc] init];
    _listOfMaybeAttending = [[NSMutableArray alloc] init];
    _listOfNotAttending = [[NSMutableArray alloc] init];
    _listOfNotResponded = [[NSMutableArray alloc] init];
}

-(void)loadTableData {
    [self initArrays];
    [self queryEventStatus:[NSNumber numberWithInt:0] intoList:self.listOfAttending];
    [self queryEventStatus:[NSNumber numberWithInt:1] intoList:self.listOfMaybeAttending];
    [self queryEventStatus:[NSNumber numberWithInt:2] intoList:self.listOfNotAttending];
    [self queryEventStatus:[NSNumber numberWithInt:3] intoList:self.listOfNotResponded];
}

-(void)queryEventStatus:(NSNumber*)attendingStatus intoList:(NSMutableArray*)statusList {
    PFQuery *eventUsers = [PFQuery queryWithClassName:@"EventUsers"];
    [eventUsers whereKey:@"eventID" equalTo:self.event.objectId];
    [eventUsers whereKey:@"attendingStatus" equalTo:attendingStatus];
    PFQuery *getAllUsersMaybeAttending = [PFUser query];
    [getAllUsersMaybeAttending whereKey:@"objectId" matchesKey:@"userID" inQuery:eventUsers];
    [getAllUsersMaybeAttending findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *error) {
        if(!error) {
            for (PFUser *object in objects) {
                [statusList addObject:object];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Attending VC"];
}

@end
