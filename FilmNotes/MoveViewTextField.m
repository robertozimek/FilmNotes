//
//  MoveViewTextField.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/25/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "MoveViewTextField.h"

@implementation MoveViewTextField

@dynamic delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self.delegate moveViewTextField:self];
    return YES;
}

-(BOOL)resignFirstResponder
{
    [self.delegate dismissMoveViewTextField:self];
    [super resignFirstResponder];
    return YES;
}

-(BOOL)isFirstResponder
{
    return [super isFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
