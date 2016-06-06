//
//  GWTNotificationView.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/6/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import "GWTNotificationView.h"

@implementation GWTNotificationView

+(instancetype)notificationViewWithMessage:(NSString *)message {
    GWTNotificationView *noteview = [[GWTNotificationView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    noteview.backgroundColor = kLightOrangeColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:noteview.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = kDarkGrayColor;
    label.font = [UIFont systemFontOfSize:18];
    label.text = message;
    [noteview addSubview:label];
    
    noteview.label = label;
    noteview.message = message;
    
    return noteview;
}

@end
