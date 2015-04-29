//
//  GWTViewFactory.m
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTViewFactory.h"
#import "GWTSettingsViewController.h"
#import "GWTEventsViewController.h"
#import "GWTEditEventViewController.h"
#import "GWTContactsViewController.h"

@implementation GWTViewFactory

-(GWTSettingsViewController*)settingsViewController {
    return [[GWTSettingsViewController alloc] init];
}

-(GWTEventsViewController*)eventsViewController {
    return [[GWTEventsViewController alloc] init];
}

-(GWTEditEventViewController*)editEventViewController {
    return [[GWTEditEventViewController alloc] init];
}

-(GWTContactsViewController*)contactsViewController {
    return [[GWTContactsViewController alloc] init];
}

@end
