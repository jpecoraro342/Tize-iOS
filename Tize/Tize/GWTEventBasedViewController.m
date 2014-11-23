//
//  GWTEventBasedViewController.m
//  Tize
//
//  Created by Joseph Pecoraro on 7/19/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEventBasedViewController.h"

@interface GWTEventBasedViewController ()

@end

@implementation GWTEventBasedViewController

-(void)reloadWithEvent:(GWTEvent *)event {
    [NSException raise:@"NSSubclassingException" format:@"Abstract class, please call the child implementation"];
}

@end
