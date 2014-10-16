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

@end

@implementation GWTAttendingTableViewController

-(void)reloadWithEvent:(GWTEvent *)event {
    self.event = event;
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
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setTitleTextAttributes:kNavBarTitleDictionary];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark table view delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.listOfAttending count];
    }
    else if (section == 1) {
        return [self.listOfMaybeAttending count];
    }
    else if (section == 2) {
        return [self.listOfNotAttending count];
    }
    else {
        return [self.listOfNotResponded count];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [[self.listOfAttending objectAtIndex:indexPath.row] username];
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = [[self.listOfMaybeAttending objectAtIndex:indexPath.row] username];
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = [[self.listOfNotAttending objectAtIndex:indexPath.row] username];
    }
    else {
        cell.textLabel.text = [[self.listOfNotResponded objectAtIndex:indexPath.row] username];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    switch (section) {
        case 0:
            titleLabel.text = @"Attending";
            break;
        case 1:
            titleLabel.text = @"Maybe Attending";
            break;
        case 2:
            titleLabel.text = @"Not Attending";
            break;
        default:
            titleLabel.text = @"Not Responded";
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

@end
