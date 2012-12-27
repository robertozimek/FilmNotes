//
//  TourImageViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/26/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "TourImageViewController.h"

@interface TourImageViewController ()

@end

@implementation TourImageViewController
@synthesize tourImageView;

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
    if([UIScreen mainScreen].bounds.size.height > 480)
        tourImageView.image = [UIImage imageNamed:@"Tour"];
 
    UISwipeGestureRecognizer *swipeDown;
    
    swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
}

-(void)handleSwipeDownFrom:(UISwipeGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"ToMain" sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
