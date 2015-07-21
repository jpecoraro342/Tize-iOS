//
//  GWTContactsListViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTTizeTableViewController.h"
#import "GWTTizeSearchTableViewController.h"

@class GWTAddressBook;

@interface GWTContactsListViewController : GWTTizeSearchTableViewController

@property (nonatomic, strong) GWTAddressBook *addressBook;

@end
