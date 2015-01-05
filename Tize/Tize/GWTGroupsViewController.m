//
//  GWTGroupsViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 11/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTGroupsViewController.h"

@interface GWTGroupsViewController () <UITabBarDelegate, UITabBarControllerDelegate>

@end

@implementation GWTGroupsViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        UITabBarItem *groups = self.tabBarItem;
        [groups setTitle:@"Groups"];
        [groups setImage:[UIImage imageNamed:@"groupstab.png"]];
    }
    return self;
}
    
-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissModal)];
    self.leftBarButtonItem = cancel;
    
    [self setSizeOfBottomBar:49];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
        case 1:
            return 0;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
    return @"My Groups";
}

-(NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return @"";
}

-(NSString*)subtitleForCellAtIndexPath:(NSIndexPath*)indexPath {
    return @"";
}

@end
