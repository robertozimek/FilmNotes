//
//  NewRollViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "RollViewController.h"
#import "MoreInfoViewController.h"
#import "DatabaseControl.h"

@interface RollViewController ()
@property (strong, nonatomic) DatabaseControl *dataController;
@property (strong, nonatomic) NSMutableArray *rollData;
@property (strong, nonatomic) NSMutableArray *exposureData;
@property (strong, nonatomic) NSString *currentExposure;
@end

@implementation RollViewController
#define kOFFSET_FOR_KEYBOARD 80.0
@synthesize aperatureTextField;
@synthesize numeratorShutterSpeedTextField;
@synthesize denominatorShutterSpeedTextField;
@synthesize focalLengthTextField;
@synthesize filmNameLabel;
@synthesize exposureLabel;
@synthesize isoLabel;
@synthesize RollNumber;
@synthesize rollData;
@synthesize exposureData;
@synthesize currentExposure;
@synthesize dataController=_dataController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(DatabaseControl *)dataController
{
    if (!_dataController) _dataController = [[DatabaseControl alloc] init];
    return _dataController;
}

- (BOOL)shouldAutorotate {
    return NO;
}


-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)dismissKeyboard
{
        [aperatureTextField resignFirstResponder];
        [numeratorShutterSpeedTextField resignFirstResponder];
        [denominatorShutterSpeedTextField resignFirstResponder];
        [focalLengthTextField resignFirstResponder];
}



-(void)handleSwipeDownFrom:(UISwipeGestureRecognizer *)recognizer {
    [self updateDatabase];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)handleSwipeRightFrom:(UISwipeGestureRecognizer *)recognizer {
    //[self goBack];
}

-(void)handleSwipeLeftFrom:(UISwipeGestureRecognizer *)recognizer {
    //[self advance];
}

-(void)updateDatabase
{
    currentExposure = [exposureLabel.text substringToIndex:[exposureLabel.text rangeOfString:@"/"].location];
    NSString *updateAperture = [NSString stringWithFormat:@"UPDATE Exposure SET Aperture = '%@' WHERE id=%@ AND Roll_id=%@",aperatureTextField.text,currentExposure,RollNumber];
    NSString *updateShutter = [NSString stringWithFormat:@"UPDATE Exposure SET Shutter = \"%@/%@\" WHERE id=%@ AND Roll_id=%@",numeratorShutterSpeedTextField.text,denominatorShutterSpeedTextField.text,currentExposure,RollNumber];
    NSString *updateFocal = [NSString stringWithFormat:@"UPDATE Exposure SET Focal = '%@' WHERE id=%@ AND Roll_id=%@",focalLengthTextField.text,currentExposure,RollNumber];
    
    [self.dataController sendSqlData:updateAperture whichTable:@"Exposure"];
    [self.dataController sendSqlData:updateShutter whichTable:@"Exposure"];
    [self.dataController sendSqlData:updateFocal whichTable:@"Exposure"];
}

-(void)advance
{
    [self updateDatabase];
    
    if(![currentExposure isEqualToString:[[rollData objectAtIndex:0]objectAtIndex:1]])
         {
             int nextExposureId = [currentExposure intValue] + 1;
             NSString *checkForNextExposure = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT id FROM Exposure WHERE id=%d AND Roll_id=%@",nextExposureId,RollNumber]];
             if(checkForNextExposure == nil)
             {
                 NSString *insertExposure = [NSString stringWithFormat:@"INSERT INTO Exposure ('id','Roll_id') VALUES ('%d','%@')",nextExposureId,RollNumber];
                 [self.dataController sendSqlData:insertExposure whichTable:@"Exposure"];
                 [self clearFields];
             }else
             {
                 [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",nextExposureId,RollNumber]];
                 
             }
         }else
         {
             
         }
    
}
-(void) goBack
{
    [self updateDatabase];
    int previousExposureId = [currentExposure intValue] - 1;
    NSString *checkForPreviousExposure = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT id FROM Exposure WHERE id=%d AND Roll_id=%@",previousExposureId,RollNumber]];
    if((checkForPreviousExposure == nil) && !(previousExposureId == 0))
    {
        NSString *insertExposure = [NSString stringWithFormat:@"INSERT INTO Exposure ('id','Roll_id')Exposure_Id INTEGER,Focal INTEGER,Aperture DOUBLE,Shutter TEXT,Gps TEXT VALUES ('%d','%@')",previousExposureId,RollNumber];
        [self.dataController sendSqlData:insertExposure whichTable:@"Exposure"];
        [self clearFields];
    }else
    {
        [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",previousExposureId,RollNumber]];
    }
}

-(void)clearFields
{
    focalLengthTextField.text = @"";
    aperatureTextField.text = @"";
    numeratorShutterSpeedTextField.text = @"";
    denominatorShutterSpeedTextField.text = @"";
}

-(void)reloadViewData:(NSString *)selectExposure
{
    [self clearFields];
    exposureData = [self.dataController readTable:selectExposure];
    
    //NSLog(@"exposureData count = %d",[[exposureData objectAtIndex:0] count]);
    if ([[exposureData objectAtIndex:0] count] == 7){
    if ([[[exposureData objectAtIndex:0] objectAtIndex:5] length]>1)
    {
        NSString *numeratorShutterData = [[[exposureData objectAtIndex:0] objectAtIndex:5] substringToIndex:[[[exposureData objectAtIndex:0] objectAtIndex:5] rangeOfString:@"/"].location];
        NSString *denominatorShutterData = [[[exposureData objectAtIndex:0] objectAtIndex:5] substringFromIndex:[[[exposureData objectAtIndex:0] objectAtIndex:5] rangeOfString:@"/"].location+1];
        numeratorShutterSpeedTextField.text = numeratorShutterData;
        denominatorShutterSpeedTextField.text  = denominatorShutterData;
    }
    
    filmNameLabel.text = [[rollData objectAtIndex:0] objectAtIndex:2];
    exposureLabel.text = [NSString stringWithFormat:@"%@/%@",[[exposureData objectAtIndex:0] objectAtIndex:0],[[exposureData objectAtIndex:0] objectAtIndex:2]];
    isoLabel.text = [NSString stringWithFormat:@"ISO %@",[[rollData objectAtIndex:0] objectAtIndex:3]];
    aperatureTextField.text = [[exposureData objectAtIndex:0] objectAtIndex:3];
    
    focalLengthTextField.text = [[exposureData objectAtIndex:0] objectAtIndex:3];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipeDown;
    
    swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeRight;
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft;
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    

    UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:48];
    UIFont *smallerFont = [UIFont fontWithName:@"Walkway SemiBold" size:14];
    UIColor *fontColor = [UIColor whiteColor];
    
    filmNameLabel.textColor = fontColor;
    filmNameLabel.textAlignment = NSTextAlignmentCenter;
    filmNameLabel.font = smallerFont;
    
    exposureLabel.textColor = fontColor;
    exposureLabel.textAlignment = NSTextAlignmentCenter;
    exposureLabel.font = generalFont;
    
    isoLabel.textColor = fontColor;
    isoLabel.textAlignment = NSTextAlignmentCenter;
    isoLabel.font = smallerFont;
    
    aperatureTextField.textColor = fontColor;
    aperatureTextField.textAlignment = NSTextAlignmentLeft;
    aperatureTextField.font = generalFont;
    aperatureTextField.placeholder = @"1.4";
    aperatureTextField.clearsOnBeginEditing = YES;
    
    numeratorShutterSpeedTextField.textColor = fontColor;
    numeratorShutterSpeedTextField.textAlignment = NSTextAlignmentRight;
    numeratorShutterSpeedTextField.font = generalFont;
    numeratorShutterSpeedTextField.placeholder = @"1";
    numeratorShutterSpeedTextField.clearsOnBeginEditing = YES;
    
    denominatorShutterSpeedTextField.textColor = fontColor;
    denominatorShutterSpeedTextField.textAlignment = NSTextAlignmentLeft;
    denominatorShutterSpeedTextField.font = generalFont;
    denominatorShutterSpeedTextField.placeholder = @"500";
    denominatorShutterSpeedTextField.clearsOnBeginEditing = YES;
    
    focalLengthTextField.textColor = fontColor;
    focalLengthTextField.textAlignment = NSTextAlignmentRight;
    focalLengthTextField.font = generalFont;
    focalLengthTextField.placeholder = @"50";
    focalLengthTextField.clearsOnBeginEditing = YES;
    NSString *selectRoll = [NSString stringWithFormat:@"SELECT * FROM Roll WHERE id=%@",RollNumber];
    NSString *selectExposure = [NSString stringWithFormat:@"SELECT * FROM Exposure WHERE roll_id=%@ AND id=1",RollNumber];
    rollData = [self.dataController readTable:selectRoll];
    [self reloadViewData:selectExposure];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)denominatorShutterSpeedEditingChanged:(id)sender {
    if((denominatorShutterSpeedTextField.text.length >= 4))
    {
        denominatorShutterSpeedTextField.text = [denominatorShutterSpeedTextField.text substringToIndex:4];
        [self performSelector:@selector(dismissKeyboard)];
    }
}

- (IBAction)aperatureEditingChanged:(id)sender {
    if((aperatureTextField.text.length >= 4)){
        aperatureTextField.text = [aperatureTextField.text substringToIndex:4];
        [self performSelector:@selector(dismissKeyboard)];
    }
}

- (IBAction)focalLengthEditingChanged:(id)sender {
    if((focalLengthTextField.text.length >= 4))
    {
        focalLengthTextField.text = [focalLengthTextField.text substringToIndex:4];
        [self performSelector:@selector(dismissKeyboard)];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int length = [textField.text length];
    if ((length >= 2 && ![string isEqualToString:@""]) && ([textField isEqual:numeratorShutterSpeedTextField])) {
        textField.text = [textField.text substringToIndex:2];
        if([textField isEqual:numeratorShutterSpeedTextField]){
            [denominatorShutterSpeedTextField becomeFirstResponder];
            denominatorShutterSpeedTextField.text = string;
        }
        return NO;
    }
    return YES;

}

- (IBAction)setGPS:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RollInfo"]) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Advance to move to the next frame.\n\nSwipe Left to go back to the previous frame.\n\nSwipe from the bottom finish roll early.\n\n";
    }
}

- (IBAction)focalLengthEditingDidBegin:(id)sender {
    [self setViewMovedUp:YES];
}
- (IBAction)focalLengthEditingDidEnd:(id)sender {
    [self setViewMovedUp:NO];
}


@end
