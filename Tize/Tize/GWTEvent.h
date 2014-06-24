//
//  GWTEvent.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface GWTEvent : PFObject <PFSubclassing>

@property (nonatomic, copy) NSString* eventName;
@property (nonatomic, copy) NSString* locationName; //the name of the location

@property (nonatomic, strong) NSDate* date;

@property (nonatomic, strong) NSString* address;

@property (nonatomic, strong) NSString* eventDetails;

+(NSString*)parseClassName;
-(NSString*)timeString;

@end
