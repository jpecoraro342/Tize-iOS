//
//  NSDateFormatter.m
//  Tize
//
//  Created by Joseph Pecoraro on 10/22/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "NSDateFormatter+RelativeDateFormat.h"

@implementation NSDateFormatter (RelativeDateFormat)

-(NSString*) relativeStringFromDateIfPossible:(NSDate *)date
{
    static NSDateFormatter *relativeFormatter;
    static NSDateFormatter *absoluteFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const NSDateFormatterStyle arbitraryStyle = NSDateFormatterShortStyle;
        
        relativeFormatter = [[NSDateFormatter alloc] init];
        [relativeFormatter setDateStyle: arbitraryStyle];
        [relativeFormatter setTimeStyle: NSDateFormatterShortStyle];
        [relativeFormatter setDoesRelativeDateFormatting: YES];
        
        absoluteFormatter = [[NSDateFormatter alloc] init];
        [absoluteFormatter setDateStyle: arbitraryStyle];
        [absoluteFormatter setTimeStyle: NSDateFormatterShortStyle];
        [absoluteFormatter setDoesRelativeDateFormatting: NO];
    });
    
    NSLocale *const locale = [self locale];
    if([relativeFormatter locale] != locale)
    {
        [relativeFormatter setLocale: locale];
        [absoluteFormatter setLocale: locale];
    }
    
    NSCalendar *const calendar = [self calendar];
    if([relativeFormatter calendar] != calendar)
    {
        [relativeFormatter setCalendar: calendar];
        [absoluteFormatter setCalendar: calendar];
    }
    
    NSString *const maybeRelativeDateString = [relativeFormatter stringFromDate: date];
    const BOOL isRelativeDateString = ![maybeRelativeDateString isEqualToString: [absoluteFormatter stringFromDate: date]];
    
    if(isRelativeDateString)
    {
        return maybeRelativeDateString;
    }
    else
    {
        return [self stringFromDate: date];
    }
}

@end