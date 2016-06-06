//
//  GWTNotificationView.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/6/16.
//  Copyright © 2016 GrayWolfTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWTNotificationView : UIView

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, copy) NSString* message;

+(instancetype)notificationViewWithMessage:(NSString*)message;

@end
