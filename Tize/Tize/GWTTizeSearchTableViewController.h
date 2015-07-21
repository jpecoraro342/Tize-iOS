//
//  GWTTizeSearchTableViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/13/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTTizeTableViewController.h"

@interface GWTTizeSearchTableViewController : GWTTizeTableViewController

-(BOOL)searchIsActive;
-(void)updateFilteredListsWithString:(NSString*)searchString;

@end
