//
//  CustomDefaultsCell.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/20/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "CustomDefaultsCell.h"

@implementation CustomDefaultsCell
@synthesize filmLabel;
@synthesize isoLabel;
@synthesize cameraLabel;
@synthesize backgroundView;
@synthesize editButton;
@synthesize index;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"initWithStyle");
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self) {
        NSLog(@"init");
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSLog(@"initWithFrame");
        [editButton setImage:[UIImage imageNamed:@"edit-arrow.png"] forState:UIControlStateNormal];
        //editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //editButton.imageView.bounds = CGRectMake(0,0,32,32);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        backgroundView.backgroundColor = [UIColor redColor];
    }else
    {
        backgroundView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    }
}

@end
