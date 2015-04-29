//
//  GWTViewFactorySingleton.h
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GWTBasePageViewController;
@class GWTEventsViewController;
@class GWTLoginViewController;
@class GWTEditEventViewController;
@class GWTEventDetailViewController;
@class GWTAttendingTableViewController;
@class GWTTizeFriendsTableViewController;
@class GWTContactsListViewController;
@class GWTGroupsViewController;
@class GWTInviteFriendsViewController;
@class GWTInviteToGroupViewController;
@class GWTContactsListViewController;
@class GWTGroupsEventInviteViewController;
@class GWTContactsViewController;
@class GWTSettingsViewController;

@interface GWTViewFactorySingleton : NSObject

+(instancetype)viewManager;

-(GWTSettingsViewController*)settingsViewController;
-(GWTEventsViewController*)eventsViewController;
-(GWTEditEventViewController*)editEventViewController;

-(GWTContactsViewController*)contactsViewController;



@end
