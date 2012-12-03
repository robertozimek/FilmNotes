//
//  CustomCell.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/28/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell
@synthesize film;
@synthesize camera;
@synthesize date;
@synthesize roll;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
