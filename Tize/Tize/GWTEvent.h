//
//  GWTEvent.h
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWTEvent : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* location; //the name of the location

@property (nonatomic, strong) NSDate* time;

@property (nonatomic, strong) NSString* address;

-(NSString*)timeString;

@end
