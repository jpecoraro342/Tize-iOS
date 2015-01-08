//
//  GWTTizeTableViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/23/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeTableViewController.h"

@interface GWTTizeTableViewController ()

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
}

-(void)setNavItems {
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.title];
    if (!self.title || [self.title isEqualToString:@""]) {
        navItem.titleView = kNavBarTitleView;
        //navItem.titleView = self.titleView;
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
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"subtitlecell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitlecell"];
    }
    
    cell.textLabel.text = [self titleForCellAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self subtitleForCellAtIndexPath:indexPath] ?: @"";
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Set the seperator insets to zero!
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    return cell;
}

//Sets the header views to the usual layout
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSInteger headerViewHeight = [self tableView:self.tableView heightForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerViewHeight)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, headerViewHeight)];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    
    titleLabel.text = [self titleForHeaderInSection:section];
    
    //UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
    //[borderView setBackgroundColor:kBorderColor];
    
    //[headerView addSubview:borderView];
    
    [headerView addSubview:titleLabel];
    return headerView;
}

-(void)setSizeOfBottomBar:(CGFloat)sizeOfBottomBar {
    [_tableViewBottom setConstant:sizeOfBottomBar];
}

#pragma mark Subclasses Must Override
                 
-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: titleForCellAtIndexPath:(NSIndexPath*)indexPath must be overriden in subclass"];
    return nil;
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: subtitleForCellAtIndexPath:(NSIndexPath*)indexPath must be overriden in subclass"];
    return nil;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    [NSException raise:@"Invalid Call to Superclass" format:@"Method: titleForHeaderInSection:(NSInteger)section must be overriden in subclass"];
    return nil;
}

#pragma mark - View Dismissal

-(void)popFromNavigationController {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    _leftBarButtonItem = leftBarButtonItem;
    [self setNavItems];
}

-(void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    _rightBarButtonItem = rightBarButtonItem;
    [self setNavItems];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Attending VC"];
}


@end
