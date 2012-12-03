//
//  MoreInfoViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "MoreInfoViewController.h"

@interface MoreInfoViewController ()

@end

@implementation MoreInfoViewController
@synthesize InfoLabel;
@synthesize InfoText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)shouldAutorotate {
    return NO;
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];
    
    
    InfoLabel.textColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:1];
    
    InfoLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:24];
    
    InfoLabel.text = InfoText;
}
- (IBAction)infoTouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
