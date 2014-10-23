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

@property (nonatomic, copy) NSString* host;
@property (nonatomic, strong) PFUser* hostUser;

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;

@property (nonatomic, strong) NSString* address;

@property (nonatomic, strong) NSString* eventDetails;

@property (nonatomic, copy) NSString* icon;

+(NSString*)parseClassName;
-(NSString*)startTime;
-(NSString*)endTime;

@end
