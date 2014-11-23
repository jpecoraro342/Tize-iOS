//
//  GWTTizeTableViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 11/23/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWTTizeTableViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) UIBarButtonItem* leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* rightBarButtonItem;

@property (nonatomic, assign) BOOL viewHasTabBar;

-(NSString*)titleForHeaderInSection:(NSInteger)section;
-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath;

@end
