//
//  NewRollViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"
#import "ViewController.h"
#import "CustomTextView.h"
#import "NumberKeypadBackSlash.h"

@interface RollViewController : UIViewController <LocationControllerDelegate>
{
    
}

@property (strong, nonatomic) IBOutlet UITextField *apertureTextField;
@property (strong, nonatomic) IBOutlet UITextField *currentExposureTextField;
@property (strong, nonatomic) IBOutlet UITextField *focalLengthTextField;
@property (strong, nonatomic) IBOutlet UITextField *shutterSpeedTextField;

@property (strong, nonatomic) IBOutlet UIButton *gpsButton;
@property (strong, nonatomic) IBOutlet UIButton *advanceButton;
@property (strong, nonatomic) IBOutlet UILabel *exposureLabel;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) IBOutlet UILabel *isoLabel;

@property (strong, nonatomic) NSString *RollNumber;
@property (strong, nonatomic) NumberKeypadBackSlash *numberKeyPad;
@property (strong, nonatomic) NSTimer *locationTimer;

@end
