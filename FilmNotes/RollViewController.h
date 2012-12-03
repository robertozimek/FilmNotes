//
//  NewRollViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface RollViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *aperatureTextField;
@property (weak, nonatomic) IBOutlet UITextField *numeratorShutterSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *denominatorShutterSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *focalLengthTextField;
@property (weak, nonatomic) IBOutlet UILabel *filmNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *exposureLabel;
@property (weak, nonatomic) IBOutlet UILabel *isoLabel;

@property (strong, nonatomic) NSString *RollNumber;

@end
