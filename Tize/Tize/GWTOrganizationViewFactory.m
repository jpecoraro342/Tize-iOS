//
//  GWTOrganizationViewFactory.m
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTOrganizationViewFactory.h"
#import "GWTOrganizationEditEventViewController.h"
#import "GWTOrganizationEventsViewController.h"
#import "GWTOrganizationSettingsViewController.h"
#import "GWTLocalSettingsManager.h"
#import "GWTEventsViewController.h"

@implementation GWTOrganizationViewFactory

-(GWTSettingsViewController*)settingsViewController {
    GWTOrganizationSettingsViewController *settings = [[GWTOrganizationSettingsViewController alloc] init];
    settings.settingsData = [[GWTLocalSettingsManager alloc] init];
    return settings;
}

-(GWTOrganizationEventsViewController*)eventsViewController {
    return [[GWTOrganizationEventsViewController alloc] init];
}

-(GWTOrganizationEditEventViewController*)editEventViewController {
    return [[GWTOrganizationEditEventViewController alloc] init];
}

-(GWTContactsViewController*)contactsViewController {
    return [super contactsViewController];
}

@end
