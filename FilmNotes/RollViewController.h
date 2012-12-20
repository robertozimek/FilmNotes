//
//  NewRollViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import "ViewController.h"
#import "CustomTextView.h"
#import "NumberKeypadBackSlash.h"

@interface RollViewController : UIViewController <MyCLControllerDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *apertureTextField;
@property (weak, nonatomic) IBOutlet UITextField *currentExposureTextField;
@property (weak, nonatomic) IBOutlet UITextField *focalLengthTextField;
@property (weak, nonatomic) IBOutlet UITextField *shutterSpeedTextField;

@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@property (weak, nonatomic) IBOutlet UILabel *exposureLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UILabel *isoLabel;

@property (strong, nonatomic) NSString *RollNumber;
@property (strong, nonatomic) NumberKeypadBackSlash *numberKeyPad;
@property (strong, nonatomic) NSTimer *locationTimer;

@end
