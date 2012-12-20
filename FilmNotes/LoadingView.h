//
//  LoadingView.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/19/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LoadingView : UIView
+(LoadingView *)loadLoadingViewIntoView:(UIView *)superView;
-(void)removeLoadingView;
@end
