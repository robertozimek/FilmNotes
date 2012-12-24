//
//  TourViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/23/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "TourViewController.h"

@interface TourViewController ()

@end

@implementation TourViewController
@synthesize tourButton;
@synthesize skipButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIFont *buttonFonts = [UIFont fontWithName:@"Walkway Semibold" size:36];
    UIColor *buttonColors = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    
    self.tourButton.titleLabel.font = buttonFonts;
    self.skipButton.titleLabel.font = buttonFonts;
    
	[self.tourButton setTitleColor:buttonColors forState:UIControlStateNormal];
    [self.skipButton setTitleColor:buttonColors forState:UIControlStateNormal];
    
    [self.tourButton setTitle:@"Tour?" forState:UIControlStateNormal];
    [self.skipButton setTitle:@"Skip" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
