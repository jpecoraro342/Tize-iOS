//
//  GWTTizeTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/23/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeTableViewController.h"

@interface GWTTizeTableViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate>

//TableView Bottom Constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;

@end

@implementation GWTTizeTableViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"GWTTizeTableViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

-(instancetype)init {
    self = [super initWithNibName:@"GWTTizeTableViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleView = kNavBarTitleView;
    [self.navigationBar setBarTintColor:kNavBarColor];
    [self.navigationBar setTintColor:kNavBarTintColor];
    
    [self setNavItems];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

-(void)setNavItems {
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.title];
    if (!self.title) {
        navItem.titleView = self.titleView;
    }
    navItem.rightBarButtonItem = self.rightBarButtonItem;
    navItem.leftBarButtonItem = self.leftBarButtonItem;
    
    [self.navigationBar setItems:@[navItem]];
    [self.navigationBar setTitleTextAttributes:kNavBarTitleDictionary];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark Table View Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: tableView: numberOfRowsInSection:section must be overriden in subclass"];
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: numberOfSectionsInTableView must be overriden in subclass"];
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForCellAtIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kOffWhiteColor;
    return cell;
}

//Sets the header views to the usual layout
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 38)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 38)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    titleLabel.text = [self titleForHeaderInSection:section];
    
    //UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
    //[borderView setBackgroundColor:kBorderColor];
    
    //[headerView addSubview:borderView];
    
    [headerView addSubview:titleLabel];
    return headerView;
}

//Setter for the view has tab bar
-(void)setViewHasTabBar:(BOOL)viewHasTabBar {
    _viewHasTabBar = viewHasTabBar;
    if (_viewHasTabBar) {
        [_tableViewBottom setConstant:49];
    }
    else {
        [_tableViewBottom setConstant:0];
    }
}

#pragma mark Subclasses Must Override
                 
-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: titleForCellAtIndexPath:(NSIndexPath*)indexPath must be overriden in subclass"];
    return nil;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: titleForHeaderInSection:(NSInteger)section must be overriden in subclass"];
    return nil;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Attending VC"];
}


@end