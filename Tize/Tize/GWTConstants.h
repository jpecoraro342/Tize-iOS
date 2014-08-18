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

//Logging
#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
//#define NSLog(...) CLS_LOG(__VA_ARGS__)
#endif

#endif