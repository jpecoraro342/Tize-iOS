//
//  GWTTizeTableViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 11/23/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//
//  This class is designed for all tableview's inside of the tize app. It gives a consistent look and feel throughout
//  the application, and is easily customizeable
//
//

#import <UIKit/UIKit.h>

@interface GWTTizeTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate>

/**
 * UITableView used in the view controller this has public access and is entirely customizable
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 * The navigation bar used in the app. By Default, we use the generic tize titleView, Green Background, White Tint, No left or right bbi
 */
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

/**
 * Adjustable title view for navigation bar
 */
@property (nonatomic, strong) UIView *titleView;

/**
 * Title for the navigation bar
 */
@property (nonatomic, copy) NSString* title;

@property (nonatomic, strong) UIBarButtonItem* leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem* rightBarButtonItem;

/**
 *  The size of bottom bar property is used to ensure that the tableview size is automatically adjusted for any bottom bar present - eg toolbar, tabbar, etc.
 */
@property (nonatomic, assign) CGFloat sizeOfBottomBar;

/**
 * Title for the header - Must be overriden if using headers
 */
-(NSString*)titleForHeaderInSection:(NSInteger)section;

/**
 * The default cells used are the "subtitle" cell. If you want to use the default, easily override the "title" property here
 */
-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 * The default cells used are the "subtitle" cell. If you want to use the default, easily override the "subtitle" property here
 */
-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 *
 */
-(void)selectedItemAtIndexPath:(NSIndexPath*)indexPath;

/**
 * Dismisses the VC Modally, should only be used if presented modally
 */
-(void)dismissModal;

/**
 * Pops the view from the navigation controller
 */
-(void)popFromNavigationController;

/**
 * Invalidates the tableview, forcing a reload
 */
-(void)reloadTableView;


@end
