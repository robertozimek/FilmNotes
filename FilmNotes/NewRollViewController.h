//
//  NewRollViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/30/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface NewRollViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *filmField;
@property (weak, nonatomic) IBOutlet UITextField *isoField;
@property (weak, nonatomic) IBOutlet UITextField *exposureField;
@property (weak, nonatomic) IBOutlet UITextField *cameraField;
@property (weak, nonatomic) IBOutlet UITextField *focalLengthField;
@property (weak, nonatomic) IBOutlet UITextField *apertureField;
@property (weak, nonatomic) IBOutlet UIButton *gpsButton;


@end
