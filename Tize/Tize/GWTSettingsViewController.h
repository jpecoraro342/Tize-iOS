//
//  GWTSettingsViewController.h
//  Tize
//
//  Created by Joseph Pecoraro on 9/24/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWTSettingsManager.h"

@interface GWTSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id<GWTSettingsManager> settingsData;

-(void)switchToOrganization;

@end
