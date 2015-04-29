//
//  GWTOrganizationViewFactory.h
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTViewFactory.h"

@class GWTContactsViewController;
@class GWTOrganizationSettingsViewController;
@class GWTOrganizationEditEventViewController;
@class GWTOrganizationEventsViewController;

@interface GWTOrganizationViewFactory : GWTViewFactory

-(GWTOrganizationSettingsViewController*)settingsViewController;
-(GWTOrganizationEventsViewController*)eventsViewController;
-(GWTOrganizationEditEventViewController*)editEventViewController;

-(GWTContactsViewController*)contactsViewController;

@end
