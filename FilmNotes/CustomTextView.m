//
//  CustomTextView.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/19/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)selectAll:(id)sender
{
    [self setSelectedRange:NSMakeRange(7,self.text.length)];
    [UIMenuController sharedMenuController].menuVisible = YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(selectAll:)) {
        //NSString *selectAllStarting = [self.text substringFromIndex:5];
        //[UIPasteboard generalPasteboard].string = selectAllStarting;
        return YES;
    }
    
    return [super canPerformAction:action withSender:sender];
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
