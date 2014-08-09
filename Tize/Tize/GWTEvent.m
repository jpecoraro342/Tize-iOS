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
@dynamic date;
@dynamic eventDetails;
@synthesize address;

//Converts the date string into a readable time format, that is also relative to today
-(NSString*)timeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self.date];
}

+(NSString*)parseClassName {
    return @"Event";
}

@end
