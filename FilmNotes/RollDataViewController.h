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

@interface RollDataViewController : UIViewController <LocationControllerDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *filmField;
@property (weak, nonatomic) IBOutlet UITextField *isoField;
@property (weak, nonatomic) IBOutlet UITextField *exposureField;
@property (weak, nonatomic) IBOutlet UITextField *cameraField;
@property (weak, nonatomic) IBOutlet UITextField *focalLengthField;
@property (weak, nonatomic) IBOutlet UITextField *apertureField;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;
@property (strong, nonatomic) IBOutlet UIButton *commitButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) NSInteger rowID;
@property (weak, nonatomic) NSString *fromView;

- (void)saveData;

@end
