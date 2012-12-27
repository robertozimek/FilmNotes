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
#import "TTAlertView.h"
#import "RDActionSheet.h"
#import "LocationController.h"
#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"

@interface RollViewController ()
@property (strong, nonatomic) DatabaseControl *dataController;
@property (weak, nonatomic) NSMutableArray *rollData;
@property (weak, nonatomic) LoadingView *loadingView;
@property (strong, nonatomic) NSMutableArray *exposureData;
@property (strong, nonatomic) NSString *currentExposure;
@property (strong, nonatomic) LocationController *locationController;
@property (strong, nonatomic) NSString *gps;
@property (strong, nonatomic) NSString *rollKey;
@end

@implementation RollViewController
#define kOFFSET_FOR_KEYBOARD 115.0
//TextFields
@synthesize apertureTextField;
@synthesize currentExposureTextField;
@synthesize focalLengthTextField;
@synthesize shutterSpeedTextField;

//Button and Labels plus Text View
@synthesize gpsButton;
@synthesize advanceButton;
@synthesize exposureLabel;
@synthesize isoLabel;
@synthesize notesTextView;

@synthesize rollNumber;
@synthesize rollKey;
@synthesize rollData;
@synthesize exposureData;
@synthesize currentExposure;

@synthesize dataController = _dataController;
@synthesize locationController;
@synthesize loadingView;
@synthesize numberKeyPad;
@synthesize gps;

//Allcating Memory for DatabaseController

-(DatabaseControl *)dataController
{
    if (!_dataController) _dataController = [[DatabaseControl alloc] init];
    return _dataController;
}

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

//Shift view up or down when editing data
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
        
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

//Dismisses Any Keyboards
- (void)dismissKeyboard
{
    [self.currentExposureTextField resignFirstResponder];
    [self.apertureTextField resignFirstResponder];
    [self.shutterSpeedTextField resignFirstResponder];
    [self.focalLengthTextField resignFirstResponder];
    [self.notesTextView resignFirstResponder];
}


//Update Database before dismissing view from swipe down
-(void)handleSwipeDownFrom:(UISwipeGestureRecognizer *)recognizer {
    [self updateDatabase];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//Animation Function 
- (void) animateData:(NSString *)direction{
    [self dismissKeyboard];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5];
	[animation setType:kCATransitionPush];
    if ([direction isEqualToString:@"Left"])
        [animation setSubtype:kCATransitionFromRight];
    else if([direction isEqualToString:@"Right"])
        [animation setSubtype:kCATransitionFromLeft];
    else if([direction isEqualToString:@"Bottom"])
        [animation setSubtype:kCATransitionFromBottom];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[self.view layer] addAnimation:animation forKey:direction];
}

//Go Back if swipe from right and dismiss keyboards
-(void)handleSwipeRightFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissKeyboard];
    [self goBack];
}

//Advance if swipe from left and dismiss keyboards
-(void)handleSwipeLeftFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissKeyboard];
    [self advance];
}

//Dismisses Keyboards and Advances to next exposure
- (IBAction)advanceButton:(id)sender {
    [self dismissKeyboard];
    [self advance];
}

//Create Exposure If It Does Not Exist Yet
-(void)checkAndCreateExposure:(int)insertExposure
{
    NSString *theExposure = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",insertExposure,self.rollNumber]];
    if([theExposure isEqualToString:@""])
    {
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"SavePreviousExposure"])
                [self clearFields];
        
        NSString *focal = @"";
        NSString *aperture = @"";
        
        if (self.focalLengthTextField.text.length > 2)
            focal = [self.focalLengthTextField.text substringToIndex:self.focalLengthTextField.text.length-2];
        if (self.apertureTextField.text.length > 2)
            aperture = [self.apertureTextField.text substringFromIndex:2];
        NSString *exposureId = [[self.exposureData objectAtIndex:0] objectAtIndex:2];
        
        [[self.exposureData objectAtIndex:0] removeAllObjects];
        [self.exposureData removeAllObjects];
        
        NSString *insertExposureToTable = [NSString stringWithFormat:@"INSERT INTO Exposure ('Id', 'Roll_Id','Exposure_Id','Focal','Aperture','Shutter','Gps','Notes') VALUES ('%d','%@','%@','%@','%@','%@','%@','%@')",insertExposure,self.rollNumber,exposureId,focal,aperture,self.shutterSpeedTextField.text,@"No GPS",@"Notes: "];
        [self.dataController sendSqlData:insertExposureToTable whichTable:@"Exposure"];
    }
    else
    {
        [[self.exposureData objectAtIndex:0] removeAllObjects];
        [self.exposureData removeAllObjects];
    }
}

//Update Database With New Data Before Loading New Data
-(void)updateDatabase
{
    //Escape quote marks from textfields
    NSString *notesEscape = [self.notesTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *focal = @"";
    NSString *aperture = @"";
    
    if (self.focalLengthTextField.text.length > 2)
        focal = [self.focalLengthTextField.text substringToIndex:self.focalLengthTextField.text.length-2];
    if (self.apertureTextField.text.length > 2)
        aperture = [self.apertureTextField.text substringFromIndex:2];
    
    //Storing sqlite update commands in NSStrings
    NSString *updateFields = [NSString stringWithFormat:@"UPDATE Exposure SET Aperture = '%@', Shutter = '%@', Focal = '%@', Notes = '%@' WHERE id='%@' AND Roll_id='%@'",aperture,self.shutterSpeedTextField.text,focal,notesEscape,self.currentExposure,self.rollNumber];
    
    //Sending sqlite update commands
    [self.dataController sendSqlData:updateFields whichTable:@"Exposure"];
}

//Load Next Exposure Data
-(void)advance
{
    int nextExposureId = [self.currentExposure intValue] + 1;
    if(!(nextExposureId > [[[self.exposureData objectAtIndex:0]objectAtIndex:2] intValue]))
         {
             [self updateDatabase];
             [self checkAndCreateExposure:nextExposureId];
             [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",nextExposureId,self.rollNumber]];
             [self animateData:@"Left"];
         }else
         {
             TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Reached End"
                                                             message:@"You have reached the last exposure, cannot go any further."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
}

//Load Previous Exposure Data
- (void)goBack
{
    int previousExposureId = [self.currentExposure intValue] - 1;
    if (!(previousExposureId < 1)){
        [self updateDatabase];
        [self checkAndCreateExposure:previousExposureId];
        [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",previousExposureId,self.rollNumber]];
        [self animateData:@"Right"];
    }else{
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Reached beginning"
                                                        message:@"You have reached the beginning, cannot go back any further."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//Clear All Textfields Except currentExposureTextField
-(void)clearFields
{
    self.focalLengthTextField.text = @"";
    self.apertureTextField.text = @"";
    self.shutterSpeedTextField.text = @"";
    self.notesTextView.text = @"Notes: ";
}

//Reload Exposure Data
-(void)reloadViewData:(NSString *)selectExposure
{
    [self clearFields];
    
    //Store All Current Exposure Data In Array
    self.exposureData = [self.dataController readTable:selectExposure];
    
    //Store Current Exposure(Number) For Use In Other Functions
    self.currentExposure = [[self.exposureData objectAtIndex:0] objectAtIndex:0];
    
    //Set Shutter Speed TextField
    if([[[self.exposureData objectAtIndex:0] objectAtIndex:5] isEqualToString:@""] && [self.currentExposure isEqualToString:@"1"] && ![[NSUserDefaults standardUserDefaults] objectForKey:self.rollKey])
        self.shutterSpeedTextField.text = @"1/500";
    else
        self.shutterSpeedTextField.text = [[self.exposureData objectAtIndex:0] objectAtIndex:5];
    
    NSLog(@"[[[NSUserDefaults standardUserDefaults] stringForKey:self.rollKey] %@",self.rollKey);
    
    //Set Current Exposure Text Field
    self.currentExposureTextField.text = [[self.exposureData objectAtIndex:0] objectAtIndex:0];
    
    //Set Total Exposure Label
    self.exposureLabel.text = [NSString stringWithFormat:@"/ %@",[[self.exposureData objectAtIndex:0] objectAtIndex:2]];
    
    NSString *aperture = [NSString stringWithFormat:@"F/%@",[[self.exposureData objectAtIndex:0] objectAtIndex:4]];
    
    //Set Aperture TextField
    if(![aperture isEqualToString:@"F/0.0"] && ![aperture isEqualToString:@"F/"] )
        if([[aperture substringFromIndex:aperture.length-2] isEqualToString:@".0"])
            self.apertureTextField.text = [aperture substringToIndex:aperture.length-2];
        else
            self.apertureTextField.text = aperture;
    else
        self.apertureTextField.text = @"";
    
    //Set Focal TextField
    if(![[[self.exposureData objectAtIndex:0] objectAtIndex:3] isEqualToString:@""])
        self.focalLengthTextField.text = [NSString stringWithFormat:@"%@mm",[[self.exposureData objectAtIndex:0] objectAtIndex:3]];
    else
        self.focalLengthTextField.text = @"";
    
    //Check If Current Exposure Has GPS Data and Determine Button Title
    if(![[[self.exposureData objectAtIndex:0] objectAtIndex:6] isEqualToString:@"No GPS"])
    {
        [self.gpsButton setTitle:@"Yes" forState:UIControlStateNormal];
    }else{
        [self.gpsButton setTitle:@"No" forState:UIControlStateNormal];
    }
    
    //Set Notes TextView
    self.notesTextView.text = [[self.exposureData objectAtIndex:0] objectAtIndex:7];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:self.currentExposureTextField.text forKey:self.rollKey];
}

//GPS Button Animation
- (void) animateButton:(NSString*)direction{
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.35];
	[animation setType:kCATransitionPush];
    if ([direction isEqualToString:@"FromBottom"])
        [animation setSubtype:kCATransitionFromBottom];
    else if ([direction isEqualToString:@"FromTop"])
        [animation setSubtype:kCATransitionFromTop];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.gpsButton layer] addAnimation:animation forKey:direction];
}

- (void)locationUpdate:(CLLocation *)location
{
    self.gps = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    self.gps= @"";
}

//Retrieve GPS Data and Insert into Sqlite Database
-(void)getGPSData{
    [self.loadingView removeLoadingView];
    NSString *insertGPS = [NSString stringWithFormat:@"UPDATE Exposure SET Gps = '%@' WHERE Id = '%@' AND Roll_Id = '%@'",self.gps,self.currentExposure,self.rollNumber];
    [self.dataController sendSqlData:insertGPS whichTable:@"Exposure"];
    [self.locationController.locationManager stopUpdatingLocation];
}

//Determine what action sheet to display with options
- (IBAction)gpsButtonPressed:(UIButton *)sender {
    [self dismissKeyboard];
    if ([[sender currentTitle] isEqualToString:@"Yes"])
    {
        RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:@"Cancel" primaryButtonTitle:@"Show Map" destroyButtonTitle:@"Clear GPS" otherButtonTitles:nil , nil];
        actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex) {
            
            switch (result) {
                case RDActionSheetButtonResultSelected:
                    NSLog(@"Pressed %i", buttonIndex);
                    if(buttonIndex == 0)
                    {
                        NSString *removeGPS = [NSString stringWithFormat:@"UPDATE Exposure SET Gps = '%@' WHERE Id = '%@' AND Roll_Id = '%@'",@"No GPS",self.currentExposure,self.rollNumber];
                        [self.dataController sendSqlData:removeGPS whichTable:@"Exposure"];
                        [self animateButton:@"FromTop"];
                        [self.gpsButton setTitle:@"No" forState:UIControlStateNormal];
                        
                    }else if (buttonIndex == 1){
                        [self updateDatabase];
                        [self performSegueWithIdentifier:@"mapSegue" sender:nil];
                    }
                    break;
                case RDActionSheetResultResultCancelled:
                    NSLog(@"Sheet cancelled");
            }
        };
        [actionSheet showFrom:self.view];
    } else
    {
        RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:@"Cancel" primaryButtonTitle:@"Get GPS" destroyButtonTitle:nil otherButtonTitles:nil , nil];
        actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex) {
            
            switch (result) {
                case RDActionSheetButtonResultSelected:
                    NSLog(@"Pressed %i", buttonIndex);
                    if(buttonIndex == 0)
                    {
                        [self.locationController.locationManager startUpdatingLocation];
                        
                        BOOL loop = YES;
                        while (loop)
                        {
                            if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
                            {
                                loop = NO;
                                self.loadingView = [LoadingView loadLoadingViewIntoView:self.view];
                                [self performSelector:@selector(getGPSData) withObject:nil afterDelay:1.0];
                                [self animateButton:@"FromBottom"];
                                [self.gpsButton setTitle:@"Yes" forState:UIControlStateNormal];
                            }
                            else if ([self.locationController.locationServicesStatus isEqualToString:@"restricted"])
                            {
                                loop = NO;
                                TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Restricted"
                                                                                message:@"Unable to retrieve GPS coordinates. Parental Controls restricts core location access."
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                                [self dismissKeyboard];
                                [self animateButton:@"FromBottom"];
                            }
                            else if ([self.locationController.locationServicesStatus isEqualToString:@"denied"] || [self.locationController.locationServicesStatus isEqualToString:@"disabled"])
                            {
                                loop = NO;
                                TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Denied"
                                                                                message:@"Unable to retrieve GPS coordinates. Location services were denied."
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                                [self dismissKeyboard];
                                [self animateButton:@"FromBottom"];
                            }
                        }
                        
                    }
                    break;
                case RDActionSheetResultResultCancelled:
                    NSLog(@"Sheet cancelled");
            }
        };
        [actionSheet showFrom:self.view];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationController = [[LocationController alloc] init];
	self.locationController.delegate = self;
    
    //Swipe Down To Dismiss
    UISwipeGestureRecognizer *swipeDown;
    
    swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
    
    //Swipe Right to Load Previous Exposure
    UISwipeGestureRecognizer *swipeRight;
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    //Swipe Left to Load Next Exposure
    UISwipeGestureRecognizer *swipeLeft;
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
     
    //Tap off screen to dismess any keyboards
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    //Formatting TextFields and Labels
    UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:26];
    UIColor *fontColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    
    self.isoLabel.font = [UIFont systemFontOfSize:28];
    self.exposureLabel.font = [UIFont systemFontOfSize:28];
     
    self.isoLabel.textColor = [UIColor redColor];
    self.exposureLabel.textColor = [UIColor redColor];
    
    self.isoLabel.textAlignment = NSTextAlignmentLeft;
    self.exposureLabel.textAlignment = NSTextAlignmentLeft;
    
    self.currentExposureTextField.textColor = fontColor;
    self.currentExposureTextField.textAlignment = NSTextAlignmentRight;
    self.currentExposureTextField.font = [UIFont systemFontOfSize:28];
    self.currentExposureTextField.clearsOnBeginEditing = YES;
    
    self.apertureTextField.textColor = fontColor;
    self.apertureTextField.textAlignment = NSTextAlignmentLeft;
    self.apertureTextField.font = generalFont;
    self.apertureTextField.placeholder = @"F/0.95";
    
    self.shutterSpeedTextField.textColor = fontColor;
    self.shutterSpeedTextField.textAlignment = NSTextAlignmentLeft;
    self.shutterSpeedTextField.font = generalFont;
    self.shutterSpeedTextField.tag = 5;
    self.shutterSpeedTextField.placeholder = @"1/500";
    
    self.focalLengthTextField.textColor = fontColor;
    self.focalLengthTextField.textAlignment = NSTextAlignmentLeft;
    self.focalLengthTextField.font = generalFont;
    self.focalLengthTextField.placeholder = @"50mm";
    
    self.notesTextView.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    self.notesTextView.font = [UIFont fontWithName:@"Walkway SemiBold" size:18];
    self.notesTextView.text = @"Notes: ";
    
    self.gpsButton.titleLabel.font = generalFont;
    [self.gpsButton setTitleColor:fontColor forState:UIControlStateNormal];
    
    self.advanceButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:42];
    [self.advanceButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    [self.advanceButton setTitle:@"Advance" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.rollKey = [NSString stringWithFormat:@"RollNumber %@",self.rollNumber];
    
    NSString *lastExposure = [[NSUserDefaults standardUserDefaults]
                              stringForKey:self.rollKey];
    
    if(!lastExposure)
        lastExposure = @"1";
    
    //Retrieve First Exposure Data
    NSString *selectRoll = [NSString stringWithFormat:@"SELECT * FROM Roll WHERE id=%@",self.rollNumber];
    NSString *selectExposure = [NSString stringWithFormat:@"SELECT * FROM Exposure WHERE roll_id=%@ AND id='%@'",self.rollNumber,lastExposure];
    
    self.rollData = [self.dataController readTable:selectRoll];
    
    //Set ISO Label
    self.isoLabel.text = [[self.rollData objectAtIndex:0] objectAtIndex:3];
    
    [[self.rollData objectAtIndex:0] removeAllObjects];
    [self.rollData removeAllObjects];
    
    [self reloadViewData:selectExposure];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

//Prevent Users From Deleting Notes Placeholder
- (BOOL)textView:(CustomTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSRange cursorPositon = [textView selectedRange];
    NSString *selectedText = [textView textInRange:textView.selectedTextRange];
    
    if ((cursorPositon.location < 7) || (((cursorPositon.location == 7) && (selectedText.length == 0)) && ([text isEqualToString:@""])))
        return NO;
    
    return YES;
}

//Shifting View Up When Editing Notes TextView
- (void)textViewDidBeginEditing:(CustomTextView *)textView
{
    if ([textView.text isEqualToString:@"Notes:"])
         textView.text = @"Notes: ";
    [self setViewMovedUp:YES];
}

//Shifting View Back Down When Finished Editing Notes TextView
- (void)textViewDidEndEditing:(CustomTextView *)textView
{
    [self setViewMovedUp:NO];
}

//Retrieve GPS Data
-(NSString *)retrieveGPSData
{
    NSString *gpsData = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT Gps FROM Exposure WHERE Id = '%@' AND Roll_Id = '%@'",self.currentExposure,self.rollNumber]];
    return gpsData;
}

//Sending data to next view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Sending More Info Data to More Info View
    if ([segue.identifier isEqualToString:@"RollInfo"]) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Advance to move to the next frame.\n\nSwipe Left to go back to the previous frame.";
    }
    //Sending GPS Data to GPS View
    if ([segue.identifier isEqualToString:@"mapSegue"]) {
        MapViewController *mapViewController = segue.destinationViewController;
        NSString *gpsData = [self retrieveGPSData];
        mapViewController.lat = [gpsData substringToIndex:[gpsData rangeOfString:@","].location];
        mapViewController.lon = [gpsData substringFromIndex:[gpsData rangeOfString:@","].location+1];
        mapViewController.exposure = self.currentExposure;
        mapViewController.camera = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT Camera FROM Roll WHERE id = '%@';",self.rollNumber]];
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.currentExposureTextField])
    {
        if((textField.text.length >2 )){
            textField.text = [textField.text substringToIndex:2];
            [self performSelector:@selector(dismissKeyboard)];
        }
    }
    if ([textField isEqual:self.shutterSpeedTextField] && ![string isEqualToString:@""])
    {
        if((textField.text.length >= 6))
        {
            textField.text = [textField.text substringToIndex:6];
            [self performSelector:@selector(dismissKeyboard)];
        }
    }
    if ([textField isEqual:self.apertureTextField])
    {
        if((textField.text.length >= 6) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:6];
            [self performSelector:@selector(dismissKeyboard)];
        }
        UITextPosition* beginning = textField.beginningOfDocument;
        
        UITextRange* selectedRange = textField.selectedTextRange;
        UITextPosition* selectionStart = selectedRange.start;
        UITextPosition* selectionEnd = selectedRange.end;
        
        const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
        const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
        
        NSRange cursorPositon = NSMakeRange(location, length);
        if((textField.text.length == cursorPositon.length) || (textField.text.length-1 == cursorPositon.length))
        {
            UITextPosition *cutOffPositon = [textField positionFromPosition:beginning offset:2];
            [textField setSelectedTextRange:[textField textRangeFromPosition:cutOffPositon toPosition:selectionEnd]];
        }
        if(((cursorPositon.location <= 2 && [string isEqualToString:@""]) || cursorPositon.location < 2) && cursorPositon.length < 1)
            return NO;
    }
    if ([textField isEqual:self.focalLengthTextField])
    {
        if((textField.text.length >= 6) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:6];
            [self performSelector:@selector(dismissKeyboard)];
        }
        
        UITextPosition* beginning = textField.beginningOfDocument;
        
        UITextRange* selectedRange = textField.selectedTextRange;
        UITextPosition* selectionStart = selectedRange.start;
        UITextPosition* selectionEnd = selectedRange.end;
        
        const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
        const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
        
        NSRange cursorPositon = NSMakeRange(location, length);
        if((textField.text.length == cursorPositon.length) || (textField.text.length-1 == cursorPositon.length))
        {
            UITextPosition *cutOffPositon = [textField positionFromPosition:selectionStart offset:textField.text.length-2];
            [textField setSelectedTextRange:[textField textRangeFromPosition:selectionStart toPosition:cutOffPositon]];
        }
        if(cursorPositon.location > textField.text.length - 2)
            return NO;
    }
    return YES;
}


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.shutterSpeedTextField]) {
        if (self.numberKeyPad) {
            self.numberKeyPad.currentTextField = textField;
        }
    }
	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.shutterSpeedTextField]) {
		/*
		 Show the numberKeyPad
		 */
		if (!self.numberKeyPad) {
			self.numberKeyPad = [NumberKeypadBackSlash keypadForTextField:textField];
		}else {
			//if we go from one field to another - just change the textfield, don't reanimate the decimal point button
			self.numberKeyPad.currentTextField = textField;
		}
	}
    if([textField isEqual:self.apertureTextField])
    {
        if([textField.text isEqualToString:@""])
            textField.text = [NSString stringWithFormat:@"F/%@",textField.text];
    }
    if([textField isEqual:self.focalLengthTextField])
    {
        if([textField.text isEqualToString:@""])
        {
            textField.text = [NSString stringWithFormat:@"%@mm",textField.text];
            textField.selectedTextRange = [textField
                                           textRangeFromPosition:textField.beginningOfDocument
                                           toPosition:textField.beginningOfDocument];
        }else
        {
            UITextPosition *cutOffPositon = [textField positionFromPosition:textField.beginningOfDocument offset:textField.text.length-2];
            textField.selectedTextRange = [textField
                                           textRangeFromPosition:cutOffPositon
                                           toPosition:cutOffPositon];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField isEqual:self.shutterSpeedTextField])
    {
        if (textField == self.numberKeyPad.currentTextField) {
            /*
             Hide the number keypad
             */
            [self.numberKeyPad removeButtonFromKeyboard];
            self.numberKeyPad = nil;
        }
    }
    if([textField isEqual:self.currentExposureTextField])
    {
        //Check If Current Exposure TextField is empty
        if([textField.text isEqualToString:@""])
            textField.text = self.currentExposure;
        //Check To Make Sure Current Exposure Does Not Exceed Total Exposures
        else if([textField.text intValue] > [[[self.exposureData objectAtIndex:0] objectAtIndex:2] intValue])
        {
            //Alerts the user if true
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Exposure Exceeded"
                                                            message:@"The current exposure cannot exceed the total number of exposures"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            textField.text = self.currentExposure;
        }
        //Check To Make Sure Current Exposure Is Not Less Then 1
        else if ([textField.text intValue] < 1)
        {
            //Alerts the user if true
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Exposure Zero."
                                                            message:@"The current exposure cannot be zero"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            textField.text = self.currentExposure;
        }
        //Update Database And Jump To Exposure
        else
        {
            [self updateDatabase]; // Updating Database
            
            //Animating Data Based On Whether The User Is Advancing Or Going Back
            if([textField.text intValue] == [self.currentExposure intValue])
                [self animateData:@"Bottom"];
            else if([textField.text intValue] > [self.currentExposure intValue])
                [self animateData:@"Left"];
            else
                [self animateData:@"Right"];
            
            //Checking If Exposure Does Not Exist and If Not Then Create Exposure
            [self checkAndCreateExposure:[textField.text intValue]];
            
            //Load The Exposure
            [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%@ AND Roll_id=%@",textField.text,self.rollNumber]];
        }
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
