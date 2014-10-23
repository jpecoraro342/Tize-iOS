//
//  NSDateFormatter.h
//  Tize
//
//  Created by Joseph Pecoraro on 10/22/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (RelativeDateFormat)

-(NSString*) relativeStringFromDateIfPossible:(NSDate *)date;

@end

