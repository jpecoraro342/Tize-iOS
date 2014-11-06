//
//  GWTEventCell.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTEventCell.h"

@implementation GWTEventCell

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (!self.shouldStayHighlighted) {
        [super setHighlighted:highlighted animated:animated];
    } 
}

@end