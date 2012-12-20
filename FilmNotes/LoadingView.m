//
//  LoadingView.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/19/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(LoadingView *)loadLoadingViewIntoView:(UIView *)superView{
    // Create a new view with the same frame size as the superView
    LoadingView *loadingView = [[LoadingView alloc] initWithFrame:superView.bounds];
    // If something's gone wrong, abort!
    if(!loadingView){ return nil; }

    loadingView.backgroundColor = [UIColor blackColor];
    loadingView.alpha = 0.8;
    
    // This is the new stuff here ;)
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    
    // Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    
    // Place it in the middle of the view
    indicator.center = superView.center;
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0,0, superView.bounds.size.width-20, 20)];
    description.center = CGPointMake(superView.center.x, superView.center.y - 50);
    description.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    description.text = @"Retrieving GPS...";
    description.backgroundColor = [UIColor clearColor];
    description.textColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    description.textAlignment = NSTextAlignmentCenter;
    
    // Add it into the loadingView
    [loadingView addSubview:indicator];
    [loadingView addSubview:description];
    
    // Start it spinning! Don't miss this step
    [indicator startAnimating];
    
    // Add the loading view to the superView. Boom.
    [superView addSubview:loadingView];
    
    // Create a new animation
    CATransition *animation = [CATransition animation];
	// Set the type to a nice wee fade
	[animation setType:kCATransitionFade];
	// Add it to the superView
	[[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    
    return loadingView;
}

-(void)removeLoadingView
{
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[[self superview] layer] addAnimation:animation forKey:@"layerAnimation"];
    [super removeFromSuperview];
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
