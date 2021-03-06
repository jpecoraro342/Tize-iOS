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

//User

#define isOrganizationUser ([[[PFUser currentUser] objectForKey:@"userType"] integerValue] == 1)

//Notification Names

#define kEventUpdated @"EventUpdatedNotification"

//Colors
#define kDarkOrangeColor rgbColor(245, 136, 101)
#define kLightOrangeColor rgbColor(250, 172, 110)
#define kDarkGrayColor rgbColor(107, 108, 107)
#define kGrayColor rgbColor(140, 140, 140)
#define kOffWhiteColor rgbColor(240, 240, 240)
#define kLightGrayColor rgbColor(167, 168, 166)
#define kRedColor rgbColor(241, 95, 90)
#define kWhiteColor rgbColor(255, 255, 255)
#define kGreenColor rgbColor(38, 131, 108)
#define kDarkerGreenColor rgbColor(38*.8, 131*.8, 108*.8)

#define kBorderColor kDarkGrayColor

#define tableViewSectionHeaderColor kWhiteColor

#define kNavBarColor kGreenColor
#define kNavBarTintColor kWhiteColor
#define kNavBarTitleDictionary @{NSForegroundColorAttributeName : kNavBarTintColor, NSFontAttributeName : [UIFont boldSystemFontOfSize:20]}
#define kNavBarTitleView [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_nav_bar.png"]]

#define kLoginLogo [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tize.png"]]

#define kIconImages @[@"tize", @"sports", @"trophy", @"entertainment", @"heart", @"party", @"outdoors", @"meeting", @"handshake", @"drinks", @"nature", @"study", @"coffee", @"present", @"movie", @"tv", @"music", @"food"]

//Logging
#ifdef DEBUG
// #define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
// #define NSLog(...) CLS_LOG(__VA_ARGS__)
#endif

#endif
