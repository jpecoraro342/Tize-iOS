//
//  GWTEvent.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEvent.h"
#import "NSDateFormatter+RelativeDateFormat.h"
#import <Parse/PFObject+Subclass.h>

@implementation GWTEvent {
    NSDateFormatter *_dateFormatter;
}

@dynamic eventName;
@dynamic locationName;
@dynamic host;
@dynamic hostUser;
@dynamic startDate;
@dynamic endDate;
@dynamic icon;
@dynamic eventDetails;
@synthesize address;

//Converts the date string into a readable time format, that is also relative to today
-(NSString*)startTime {
    if (!_dateFormatter) {
        [self initDateFormatter];
    }
    return [_dateFormatter relativeStringFromDateIfPossible:self.startDate];
}

-(NSString*)endTime {
    if (!_dateFormatter) {
        [self initDateFormatter];
    }
    return [_dateFormatter relativeStringFromDateIfPossible:self.endDate];
}

-(void)initDateFormatter {
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MMM dd hh:mm a"];
    //[_dateFormatter setDoesRelativeDateFormatting:YES];
}

+(NSString*)parseClassName {
    return @"Event";
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Event Name: %@\nEventHost: %@", self.eventName, self.hostUser.username];
}

@end
