//
//  GWTConstants.h
//  Tize
//
//  Created by Joseph Pecoraro on 7/14/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#ifndef Tize_GWTConstants_h
#define Tize_GWTConstants_h

#import "GWTExtendedNSLog.h"
#import <Crashlytics/Crashlytics.h>

#define rgbColor(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

//Colors
#define kDarkOrangeColor rgbColor(245, 136, 101)
#define kLightOrangeColor rgbColor(250, 172, 110)
#define kDarkGrayColor rgbColor(107, 108, 107)
#define kLightGrayColor rgbColor(167, 168, 166)
#define kGreenColor rgbColor(137,176,149)
#define kRedColor rgbColor(241, 95, 90)
#define kLightBlueColor rgbColor(12, 110, 220)
#define kQuiteBlueColor rgbColor(15, 60, 240)
#define kVeryBlueColor rgbColor(18, 73, 255)
#define kWhiteColor rgbColor(255, 255, 255)
#define kBrightOrange rgbColor(255, 149, 0)

#define kBorderColor kDarkGrayColor
#define kNavBarColor kLightBlueColor
#define kNavBarTintColor kWhiteColor
#define kNavBarTitleView [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_nav_bar.png"]]

//Logging
#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(...) CLS_LOG(__VA_ARGS__)
#endif

#endif
