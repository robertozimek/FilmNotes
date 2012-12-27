//
//  NewRollViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/30/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"
#import <sqlite3.h>
#import "MoveViewTextField.h"

@interface RollDataViewController : UIViewController <LocationControllerDelegate,MoveViewTextFieldDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *filmField;
@property (weak, nonatomic) IBOutlet UITextField *isoField;
@property (weak, nonatomic) IBOutlet UITextField *exposureField;
@property (weak, nonatomic) IBOutlet UITextField *cameraField;
@property (weak, nonatomic) IBOutlet MoveViewTextField *focalLengthField;
@property (weak, nonatomic) IBOutlet MoveViewTextField *apertureField;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) NSInteger rowID;
@property (assign, nonatomic) NSInteger commitTag;

- (void)saveData;
- (IBAction)gpsButtonPressed:(UIButton *)sender;

@end
