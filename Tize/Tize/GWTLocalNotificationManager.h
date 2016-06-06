//
//  GWTLocalNotificationManager.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/6/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWTEvent.h"

@interface GWTLocalNotificationManager : NSObject

-(void)scheduleNotificationForEvent:(GWTEvent*)event;
-(void)cancelNotificationForEvent:(GWTEvent*)event;

@end
