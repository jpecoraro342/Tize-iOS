//
//  GWTIconCell.m
//  Tize
//
//  Created by Joseph Pecoraro on 10/22/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTIconCell.h"

@implementation GWTIconCell

-(void)setSelected:(BOOL)selected {
    self.checkMark.hidden = !selected;
}

@end
