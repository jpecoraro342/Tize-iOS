//
//  GWTOrganizationEventsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 3/18/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTOrganizationEventsViewController.h"
#import "GWTEventCell.h"

@interface GWTOrganizationEventsViewController ()

//Properties from Super Class
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray* upcomingEvents;
@property (strong, nonatomic) NSMutableArray* myEvents;
@property (strong, nonatomic) NSMutableArray* myPastEvents;

@property (strong, nonatomic) NSMutableDictionary* attendingStatusMap;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) NSMutableArray *cellIsSelected;
@property (strong, nonatomic) NSIndexPath *indexPathForSwipingCell;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation GWTOrganizationEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadOrganizationToolbar];
}

//NOTE: Be wary of this breaking
-(void)loadOrganizationToolbar {
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    UIBarButtonItem *groups = [[UIBarButtonItem alloc] initWithTitle:@"Groups" style:UIBarButtonItemStyleBordered target:self action:@selector(loadGroups)];
    [toolbarItems removeLastObject];
    [toolbarItems addObject:groups];
    
    [self.toolbar setItems:toolbarItems];
}

-(void)loadGroups {
    
}

#pragma mark Tableview Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [super tableView:self.tableView viewForHeaderInSection:section + 1];
}

-(GWTEvent *)eventForIndexPath:(NSIndexPath*)indexPath {
    GWTEvent *tempEvent;
    switch (indexPath.section) {
        case 0: {
            tempEvent = [self.upcomingEvents objectAtIndex:indexPath.row];
            break;
        }
        case 1: {
            tempEvent = [self.myEvents objectAtIndex:indexPath.row];
            break;
        }
        case 2: {
            tempEvent = [self.myPastEvents objectAtIndex:indexPath.row];
            break;
        }
    }
    
    return tempEvent;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:self.tableView numberOfRowsInSection:section + 1];
}

#pragma mark - Query

-(void)queryEvents {
    [self queryMyEvents];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
