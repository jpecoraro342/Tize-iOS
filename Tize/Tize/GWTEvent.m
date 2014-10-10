//
//  GWTEvent.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEvent.h"
#import <Parse/PFObject+Subclass.h>

@implementation GWTEvent


@dynamic eventName;
@dynamic locationName;
@dynamic host;
@dynamic hostUser;
@dynamic startDate;
@dynamic endDate;
@dynamic eventDetails;
@synthesize address;

//Converts the date string into a readable time format, that is also relative to today
-(NSString*)startTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self.startDate];
}

-(NSString*)endTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self.endDate];
}

+(NSString*)parseClassName {
    return @"Event";
}

@end
