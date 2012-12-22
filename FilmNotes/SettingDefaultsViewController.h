//
//  SettingDefaultsViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/20/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SettingDefaultsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *filmTextField;
@property (weak, nonatomic) IBOutlet UITextField *isoTextField;
@property (strong, nonatomic) IBOutlet UITextField *exposureTextField;
@property (weak, nonatomic) IBOutlet UITextField *cameraTextField;
@property (strong, nonatomic) IBOutlet UITextField *focalTextField;
@property (strong, nonatomic) IBOutlet UITextField *apertureTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *defaultLabel;
@property (strong, nonatomic) IBOutlet UIButton *gpsButton;
@property (assign,nonatomic) BOOL update;
@property (assign, nonatomic) NSInteger rowID;
@property (strong, nonatomic) NSArray *data;

@end
