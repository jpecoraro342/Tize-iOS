//
//  GWTViewFactorySingleton.m
//  Tize
//
//  Created by Joseph Pecoraro on 4/29/15.
//  Copyright (c) 2015 GrayWolfTechnologies. All rights reserved.
//

#import "GWTViewFactorySingleton.h"
#import "GWTViewFactory.h"
#import "GWTOrganizationViewFactory.h"
#import "Parse.h"

@implementation GWTViewFactorySingleton {
    GWTViewFactory *_internalFactory;
    NSInteger _currentStatus;
}

//returns singleton instance
+ (instancetype)viewManager
{
    static GWTViewFactorySingleton *viewManager= nil;
    
    //makes the singleton thread safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        viewManager = [[self alloc] initDefault];
    });
    
    [viewManager sanityCheck];
    return viewManager;
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + viewManager" userInfo:nil];
    return nil;
}

-(instancetype) initDefault {
    self = [super init];
    if (self) {
        _currentStatus = -1;
        [self sanityCheck];
    }
    return self;
}

-(void)sanityCheck {
    if (![PFUser currentUser] || [[[PFUser currentUser] objectForKey:@"userType"] integerValue] == 0) {
        if (_currentStatus != 0) {
            [self reloadAsUser];
        }
    }
    else {
        if (_currentStatus != 1) {
            [self reloadAsOrganization];
        }
    }
}

-(void)reloadAsOrganization {
    _internalFactory = [[GWTOrganizationViewFactory alloc] init];
    _currentStatus = 1;
}

-(void)reloadAsUser {
    _internalFactory = [[GWTViewFactory alloc] init];
    _currentStatus = 0;
}


-(GWTSettingsViewController*)settingsViewController {
    return _internalFactory.settingsViewController;
}

-(GWTEventsViewController*)eventsViewController {
    return _internalFactory.eventsViewController;
}

-(GWTEditEventViewController*)editEventViewController {
    return _internalFactory.editEventViewController;
}

-(GWTContactsViewController*)contactsViewController {
    return _internalFactory.contactsViewController;
}

@end
