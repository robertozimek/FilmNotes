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
@property (strong, nonatomic) NSMutableArray *rollData;
@property (strong, nonatomic) LoadingView *loadingView;
@property (strong, nonatomic) NSMutableArray *exposureData;
@property (strong, nonatomic) NSString *currentExposure;
@property (strong, nonatomic) LocationController *locationController;
@property (strong, nonatomic) NSString *gps;
@property (strong, nonatomic) NSString *rollKey;
@end

@implementation RollViewController
#define kOFFSET_FOR_KEYBOARD 120.0
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

@synthesize RollNumber;
@synthesize rollKey;
@synthesize rollData;
@synthesize exposureData;
@synthesize currentExposure;

@synthesize dataController=_dataController;
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

//Dismisses Any Keyboards
- (void)dismissKeyboard
{
    [currentExposureTextField resignFirstResponder];
    [apertureTextField resignFirstResponder];
    [shutterSpeedTextField resignFirstResponder];
    [focalLengthTextField resignFirstResponder];
    [notesTextView resignFirstResponder];
}


//Update Database before dismissing view from swipe down
-(void)handleSwipeDownFrom:(UISwipeGestureRecognizer *)recognizer {
    [self updateDatabase];
    [[NSUserDefaults standardUserDefaults]
     setObject:currentExposureTextField.text forKey:rollKey];
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
    [[NSUserDefaults standardUserDefaults]
     setObject:currentExposureTextField.text forKey:rollKey];
    [self goBack];
}

//Advance if swipe from left and dismiss keyboards
-(void)handleSwipeLeftFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissKeyboard];
    [[NSUserDefaults standardUserDefaults]
     setObject:currentExposureTextField.text forKey:rollKey];
    [self advance];
}

//Dismisses Keyboards and Advances to next exposure
- (IBAction)advanceButton:(id)sender {
    [self dismissKeyboard];
    [[NSUserDefaults standardUserDefaults]
     setObject:currentExposureTextField.text forKey:rollKey];
    [self advance];
}

//Create Exposure If It Does Not Exist Yet
-(void)checkAndCreateExposure:(int)insertExposure
{
    NSString *theExposure = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",insertExposure,RollNumber]];
    if([theExposure isEqualToString:@""])
    {
        NSString *insertExposureToTable = [NSString stringWithFormat:@"INSERT INTO Exposure ('Id', 'Roll_Id','Exposure_Id','Gps','Notes') VALUES ('%d','%@','%@','%@','%@')",insertExposure,RollNumber,[[rollData objectAtIndex:0] objectAtIndex:1],@"No GPS",@"Notes: "];
        [self.dataController sendSqlData:insertExposureToTable whichTable:@"Exposure"];
    }
}

//Update Database With New Data Before Loading New Data
-(void)updateDatabase
{
    //Escape quote marks from textfields
    NSString *shutterEscape = [shutterSpeedTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *notesEscape = [notesTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *focal = @"";
    NSString *aperture = @"";
    
    if (focalLengthTextField.text.length > 2)
        focal = [focalLengthTextField.text substringToIndex:focalLengthTextField.text.length-2];
    if (apertureTextField.text.length > 2)
        aperture = [apertureTextField.text substringFromIndex:2];
    
    //Storing sqlite update commands in NSStrings
    NSString *updateAperture = [NSString stringWithFormat:@"UPDATE Exposure SET Aperture = '%@' WHERE id=%@ AND Roll_id=%@",aperture,currentExposure,RollNumber];
    NSString *updateShutter = [NSString stringWithFormat:@"UPDATE Exposure SET Shutter = '%@' WHERE id=%@ AND Roll_id=%@",shutterEscape,currentExposure,RollNumber];
    NSString *updateFocal = [NSString stringWithFormat:@"UPDATE Exposure SET Focal = '%@' WHERE id=%@ AND Roll_id=%@",focal,currentExposure,RollNumber];
    NSString *updateNotes = [[NSString stringWithFormat:@"UPDATE Exposure SET Notes = '%@' WHERE id=%@ AND Roll_id=%@",notesEscape,currentExposure,RollNumber] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\'"];
    
    //Sending sqlite update commands
    [self.dataController sendSqlData:updateAperture whichTable:@"Exposure"];
    [self.dataController sendSqlData:updateShutter whichTable:@"Exposure"];
    [self.dataController sendSqlData:updateFocal whichTable:@"Exposure"];
    [self.dataController sendSqlData:updateNotes whichTable:@"Exposure"];
}

//Load Next Exposure Data
-(void)advance
{
    int nextExposureId = [currentExposure intValue] + 1;
    if(!(nextExposureId > [[[rollData objectAtIndex:0]objectAtIndex:1] intValue]))
         {
             [self updateDatabase];
             [self clearFields];
             [self checkAndCreateExposure:nextExposureId];
             [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",nextExposureId,RollNumber]];
             [self animateData:@"Left"];
         }else
         {
             TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Reach End"
                                                             message:@"You have reached the last last exposure, cannot go any farther"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }
}

//Load Previous Exposure Data
-(void) goBack
{
    int previousExposureId = [currentExposure intValue] - 1;
    if (!(previousExposureId < 1)){
        [self updateDatabase];
        [self clearFields];
        [self checkAndCreateExposure:previousExposureId];
        [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%d AND Roll_id=%@",previousExposureId,RollNumber]];
        [self animateData:@"Right"];
    }else{
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Reach beginning"
                                                        message:@"You have reached the beginning, cannot go back any farther"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//Clear All Textfields Except currentExposureTextField
-(void)clearFields
{
    focalLengthTextField.text = @"";
    apertureTextField.text = @"";
    shutterSpeedTextField.text = @"";
    notesTextView.text = @"Notes: ";
}

//Reload Exposure Data
-(void)reloadViewData:(NSString *)selectExposure
{
    [self clearFields];
    
    //Store All Current Exposure Data In Array
    exposureData = [self.dataController readTable:selectExposure];
    
    //Store Current Exposure(Number) For Use In Other Functions
    currentExposure = [[exposureData objectAtIndex:0] objectAtIndex:0];
    
    //Set Shutter Speed TextField 
    shutterSpeedTextField.text = [[exposureData objectAtIndex:0] objectAtIndex:5];
    
    //Set Film and ISO Label
    isoLabel.text = [[rollData objectAtIndex:0] objectAtIndex:3];
    
    //Set Current Exposure Text Field
    currentExposureTextField.text = [[exposureData objectAtIndex:0] objectAtIndex:0];
    
    //Set Total Exposure Label
    exposureLabel.text = [NSString stringWithFormat:@"/ %@",[[exposureData objectAtIndex:0] objectAtIndex:2]];
    
    //Set Aperture TextField
    if(![[[exposureData objectAtIndex:0] objectAtIndex:4] isEqualToString:@""])
       apertureTextField.text = [NSString stringWithFormat:@"F/%@",[[exposureData objectAtIndex:0] objectAtIndex:4]];
    else
        apertureTextField.text = @"";
    
    //Set Focal TextField
    if(![[[exposureData objectAtIndex:0] objectAtIndex:3] isEqualToString:@""])
        focalLengthTextField.text = [NSString stringWithFormat:@"%@mm",[[exposureData objectAtIndex:0] objectAtIndex:3]];
    else
        focalLengthTextField.text = @"";
    
    //Check If Current Exposure Has GPS Data and Determine Button Title
    if(![[[exposureData objectAtIndex:0] objectAtIndex:6] isEqualToString:@"No GPS"])
    {
        [gpsButton setTitle:@"Yes" forState:UIControlStateNormal];
    }else{
        [gpsButton setTitle:@"No" forState:UIControlStateNormal];
    }
    
    //Set Notes TextView
    notesTextView.text = [[exposureData objectAtIndex:0] objectAtIndex:7];
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
    [[gpsButton layer] addAnimation:animation forKey:direction];
}

- (void)locationUpdate:(CLLocation *)location
{
    gps = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    
}

//Retrieve GPS Data and Insert into Sqlite Database
-(void)getGPSData{
    [loadingView removeLoadingView];
    NSString *insertGPS = [NSString stringWithFormat:@"UPDATE Exposure SET Gps = '%@' WHERE Id = '%@' AND Roll_Id = '%@'",gps,currentExposure,RollNumber];
    [self.dataController sendSqlData:insertGPS whichTable:@"Exposure"];
    [locationController.locationManager stopUpdatingLocation];
}

//Determine what action sheet to display with options
- (IBAction)gpsButtonPressed:(id)sender {
    [self dismissKeyboard];
    if ([[gpsButton currentTitle] isEqualToString:@"Yes"])
    {
        RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:@"Cancel" primaryButtonTitle:@"Show Map" destroyButtonTitle:@"Clear GPS" otherButtonTitles:nil , nil];
        actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex) {
            
            switch (result) {
                case RDActionSheetButtonResultSelected:
                    NSLog(@"Pressed %i", buttonIndex);
                    if(buttonIndex == 0)
                    {
                        NSString *removeGPS = [NSString stringWithFormat:@"UPDATE Exposure SET Gps = '%@' WHERE Id = '%@' AND Roll_Id = '%@'",@"No GPS",currentExposure,RollNumber];
                        [self.dataController sendSqlData:removeGPS whichTable:@"Exposure"];
                        [self animateButton:@"FromTop"];
                        [gpsButton setTitle:@"No" forState:UIControlStateNormal];
                        
                    }else if (buttonIndex == 1){
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
                        [locationController.locationManager startUpdatingLocation];
                        if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
                        {
                            loadingView = [LoadingView loadLoadingViewIntoView:self.view];
                            [self performSelector:@selector(getGPSData) withObject:nil afterDelay:1.0];
                        }else
                        {
                            BOOL loop = YES;
                            while (loop)
                            {
                                if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
                                {
                                    loop = NO;
                                    loadingView = [LoadingView loadLoadingViewIntoView:self.view];
                                    [self performSelector:@selector(getGPSData) withObject:nil afterDelay:1.0];
                                }
                            }
                            
                        }
                        [self animateButton:@"FromBottom"];
                        [gpsButton setTitle:@"Yes" forState:UIControlStateNormal];
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
    locationController = [[LocationController alloc] init];
	locationController.delegate = self;
    
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
    
    isoLabel.textColor = [UIColor redColor];
    isoLabel.font = [UIFont systemFontOfSize:28];
    isoLabel.textAlignment = NSTextAlignmentLeft;
    
    exposureLabel.textColor = [UIColor redColor];
    exposureLabel.font = [UIFont systemFontOfSize:28];
    exposureLabel.textAlignment = NSTextAlignmentLeft;
    
    currentExposureTextField.textColor = fontColor;
    currentExposureTextField.textAlignment = NSTextAlignmentRight;
    currentExposureTextField.font = [UIFont systemFontOfSize:28];
    currentExposureTextField.clearsOnBeginEditing = YES;
    
    apertureTextField.textColor = fontColor;
    apertureTextField.textAlignment = NSTextAlignmentLeft;
    apertureTextField.font = generalFont;
    apertureTextField.placeholder = @"F/0.95";
    
    shutterSpeedTextField.textColor = fontColor;
    shutterSpeedTextField.textAlignment = NSTextAlignmentLeft;
    shutterSpeedTextField.font = generalFont;
    shutterSpeedTextField.tag = 5;
    shutterSpeedTextField.placeholder = @"1/500";
    
    focalLengthTextField.textColor = fontColor;
    focalLengthTextField.textAlignment = NSTextAlignmentLeft;
    focalLengthTextField.font = generalFont;
    focalLengthTextField.placeholder = @"50mm";
    
    notesTextView.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    notesTextView.font = [UIFont fontWithName:@"Walkway SemiBold" size:18];
    notesTextView.text = @"Notes: ";
    
    gpsButton.titleLabel.font = generalFont;
    [gpsButton setTitleColor:fontColor forState:UIControlStateNormal];
    
    advanceButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:42];
    [advanceButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    [advanceButton setTitle:@"Advance" forState:UIControlStateNormal];
    
    rollKey = [NSString stringWithFormat:@"RollNumber %@",RollNumber];
    
    NSString *lastExposure = [[NSUserDefaults standardUserDefaults]
                              stringForKey:rollKey];
    if(!lastExposure)
        lastExposure = @"1";
      
    //Retrieve First Exposure Data
    NSString *selectRoll = [NSString stringWithFormat:@"SELECT * FROM Roll WHERE id=%@",RollNumber];
    NSString *selectExposure = [NSString stringWithFormat:@"SELECT * FROM Exposure WHERE roll_id=%@ AND id='%@'",RollNumber,lastExposure];
    rollData = [self.dataController readTable:selectRoll];  
    [self reloadViewData:selectExposure];
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
    NSString *gpsData = [self.dataController singleRead:[NSString stringWithFormat:@"SELECT Gps FROM Exposure WHERE Id = '%@' AND Roll_Id = '%@'",currentExposure,RollNumber]];
    return gpsData;
}

//Sending data to next view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Sending More Info Data to More Info View
    if ([segue.identifier isEqualToString:@"RollInfo"]) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Advance to move to the next frame.\n\nSwipe Left to go back to the previous frame.\n\nSwipe from the bottom finish roll early.\n\n";
    }
    //Sending GPS Data to GPS View
    if ([segue.identifier isEqualToString:@"mapSegue"]) {
        MapViewController *mapViewController = segue.destinationViewController;
        NSString *gpsData = [self retrieveGPSData];
        mapViewController.lat = [gpsData substringToIndex:[gpsData rangeOfString:@","].location];
        mapViewController.lon = [gpsData substringFromIndex:[gpsData rangeOfString:@","].location+1];
        mapViewController.exposure = currentExposure;
    }
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:currentExposureTextField])
    {
        if((textField.text.length >2 )){
            textField.text = [textField.text substringToIndex:2];
            [self performSelector:@selector(dismissKeyboard)];
        }
    }
    if ([textField isEqual:shutterSpeedTextField] && ![string isEqualToString:@""])
    {
        if((textField.text.length >= 6))
        {
            textField.text = [textField.text substringToIndex:6];
            [self performSelector:@selector(dismissKeyboard)];
        }
    }
    if ([textField isEqual:apertureTextField])
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
    if ([textField isEqual:focalLengthTextField])
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
    if ([textField isEqual:shutterSpeedTextField]) {
        if (numberKeyPad) {
            numberKeyPad.currentTextField = textField;
        }
    }
	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:shutterSpeedTextField]) {
		/*
		 Show the numberKeyPad
		 */
		if (!self.numberKeyPad) {
			self.numberKeyPad = [NumberKeypadBackSlash keypadForTextField:textField];
		}else {
			//if we go from one field to another - just change the textfield, don't reanimate the decimal point button
			self.numberKeyPad.currentTextField = textField;
		}
        NSLog(@"numberKeyPad: %@, self.numberKeyPad: %@, !self.numberKeyPad: %d",numberKeyPad,self.numberKeyPad,!self.numberKeyPad);
	}
    if([textField isEqual:apertureTextField])
    {
        if([textField.text isEqualToString:@""])
            textField.text = [NSString stringWithFormat:@"F/%@",textField.text];
    }
    if([textField isEqual:focalLengthTextField])
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
	if ([textField isEqual:shutterSpeedTextField])
    {
        if (textField == numberKeyPad.currentTextField) {
            /*
             Hide the number keypad
             */
            [self.numberKeyPad removeButtonFromKeyboard];
            self.numberKeyPad = nil;
        }
    }
    if([textField isEqual:currentExposureTextField])
    {
        //Check If Current Exposure TextField is empty
        if([textField.text isEqualToString:@""])
            textField.text = currentExposure;
        //Check To Make Sure Current Exposure Does Not Exceed Total Exposures
        else if([textField.text intValue] > [[[rollData objectAtIndex:0] objectAtIndex:1] intValue])
        {
            //Alerts the user if true
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Exposure Exceeded"
                                                            message:@"The current exposure cannot exceed the total number of exposures"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            textField.text = currentExposure;
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
            textField.text = currentExposure;
        }
        //Update Database And Jump To Exposure
        else
        {
            [self updateDatabase]; // Updating Database
            
            [[NSUserDefaults standardUserDefaults]
             setObject:currentExposureTextField.text forKey:rollKey];
            
            //Animating Data Based On Whether The User Is Advancing Or Going Back
            if([textField.text intValue] == [currentExposure intValue])
                [self animateData:@"Bottom"];
            else if([textField.text intValue] > [currentExposure intValue])
                [self animateData:@"Left"];
            else
                [self animateData:@"Right"];
            
            //Checking If Exposure Does Not Exist and If Not Then Create Exposure
            [self checkAndCreateExposure:[textField.text intValue]];
            
            //Load The Exposure
            [self reloadViewData:[NSString stringWithFormat:@"SELECT * FROM Exposure WHERE id=%@ AND Roll_id=%@",textField.text,RollNumber]];
        }
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
