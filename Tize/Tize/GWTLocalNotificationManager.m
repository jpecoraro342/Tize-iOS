//
//  GWTLocalNotificationManager.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/6/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import "GWTLocalNotificationManager.h"

@implementation GWTLocalNotificationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.settings = [[GWTNetworkedSettingsManager alloc] init];
    }
    return self;
}

-(void)scheduleNotificationForEvent:(GWTEvent*)event {
    if (!self.settings.upcomingEvents) {
        return;
    }
    
    NSDate *startTime = [event.startDate dateByAddingTimeInterval:-60*60]; // 1 hour before event start date
    NSString *message = [NSString stringWithFormat:@"%@ is starting soon", event.eventName];
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    [note setFireDate:startTime];
    [note setAlertBody:message];
    
    [note setUserInfo:@{ @"id" : event.objectId }];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

-(void)cancelNotificationForEvent:(GWTEvent*)event {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i = 0; i < [notifications count]; i++)
    {
        UILocalNotification *note = [notifications objectAtIndex:i];
        NSDictionary *userInfo = note.userInfo;
        NSString *notId = [userInfo valueForKey:@"id"];
        if ([notId isEqualToString:event.objectId])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:note];
            break;
        }
    }
}


@end
