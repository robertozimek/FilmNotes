//
//  NewRollViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/30/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "RollDataViewController.h"
#import "DatabaseControl.h"
#import "MoreInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h> 
#import "TTAlertView.h"
#import "LoadingView.h"

@interface RollDataViewController ()
@property (weak, nonatomic) LoadingView *loadingView;
@property (strong, nonatomic) DatabaseControl *dataController;
@property (strong, nonatomic) LocationController *locationController;
@property (assign, nonatomic) NSInteger defaultID;
@property (strong, nonatomic) NSString *gps;
@property (strong, nonatomic) NSArray *data;
@property (assign, nonatomic) CGRect rect;
@end

@implementation RollDataViewController
#define kOFFSET_FOR_KEYBOARD 65.0
@synthesize filmField;
@synthesize isoField;
@synthesize exposureField;
@synthesize cameraField;
@synthesize focalLengthField;
@synthesize apertureField;
@synthesize gpsButton;
@synthesize commitButton;
@synthesize locationController;
@synthesize loadingView;
@synthesize gps;
@synthesize data;
@synthesize titleLabel;
@synthesize rowID;
@synthesize commitTag;
@synthesize defaultID;
@synthesize rect;
@synthesize dataController = _dataController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Lazy Instantiation of DatabaseControl
-(DatabaseControl *)dataController
{
    if (!_dataController) _dataController = [[DatabaseControl alloc] init];
    return _dataController;
}

#pragma mark - Commit and GPS button action methods

- (IBAction)commitButtonPressed:(UIButton *)sender {
    //If commit button tag is one execute startData Method
    if(sender.tag == 1)
        [self startData];
    //If commit button tag is 2 or 3 determine if required text fields filled
    else if (sender.tag == 2 || sender.tag == 3)
    {
        if ((![self.filmField.text isEqualToString:@""] && ![self.isoField.text isEqualToString:@""] && ![self.cameraField.text isEqualToString:@""]) || ![self.exposureField.text isEqualToString:@""] || !([self.focalLengthField.text isEqualToString:@""] || [self.focalLengthField.text isEqualToString:@"mm"]) || !([self.apertureField.text isEqualToString:@""] || [self.apertureField.text isEqualToString:@"F/"]))
        {
            //If the commitbutton tag is 3 update the preset
            if(sender.tag == 3)
                [self updateData];
            //Other wise save preset
            else
                [self saveData];
        }else
        {
            //If required textfields are empty display an alert
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Roll Not Saved"
                                                            message:@"Roll was not saved because required fields film, iso,camera are empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    //Dismiss the view controller from view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)gpsButtonPressed:(UIButton *)sender {
    //If commitButton tag is equal to 1 change title of button base on gps button tag
    if(self.commitButton.tag == 1)
    {
        //Dismiss any keyboard
        [self dismissKeyboard];
        
        //If gps button tag is 0 change button title to YES and retrieve GPS cooridnates
        if(sender.tag == 0)
        {
            [self.locationController.locationManager requestWhenInUseAuthorization];
            //Start the location manager
            [self.locationController.locationManager startUpdatingLocation];
            
            //Start a loop while user accepts or denies core location services
            BOOL loop = YES;
            while (loop)
            {
                //If user accepted core location access get gps coordinates
                if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
                {
                    //Turn off loop
                    loop = NO;
                    
                    //Start the loading view
                    self.loadingView = [LoadingView loadLoadingViewIntoView:self.view];
                    
                    //Retrieve GPS coordinates after a delay
                    [self performSelector:@selector(retrieveGPS) withObject:nil afterDelay:1.2];
                    
                    //Animate the change of Button Title
                    [self animateButton:@"FromBottom"];
                    
                    //Set GPS button tag to 1
                    sender.tag = 1;
                    
                    //Change button title to YES
                    [sender setTitle:@"YES" forState: UIControlStateNormal];
                    
                //If core locations is restricted by parental control show alert view
                }else if ([self.locationController.locationServicesStatus isEqualToString:@"restricted"])
                {
                    //Stop loop
                    loop = NO;
                    
                    //Show alert informing user of restricted access.
                    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Restricted"
                                                                    message:@"Unable to retrieve GPS coordinates. Parental Controls restricts core location access."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                    //Dismiss any keyboard on screen
                    [self dismissKeyboard];
                    
                    //Animate Button with no title change
                    [self animateButton:@"FromBottom"];
                }
                //If user denied core locations access alert user that gps can't be retrieved
                else if ([self.locationController.locationServicesStatus isEqualToString:@"denied"] || [self.locationController.locationServicesStatus isEqualToString:@"disabled"])
                {
                    //Stop loop
                    loop = NO;
                    
                    //Show alert
                    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Denied"
                                                                        message:@"Unable to retrieve GPS coordinates. Location services were denied."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alert show];
                    
                    //Dismiss any keyboard on screen
                    [self dismissKeyboard];
                    
                    //Animate button with no title change
                    [self animateButton:@"FromBottom"];
                }
            }
        }
        //If the button tag is 1 set it to 0 and remove gps data
        else
        {
            //Animate button as title changes
            [self animateButton:@"FromTop"];
            
            //Set GPS to No GPS
            self.gps = @"No GPS";
            
            //Set button tag to 0
            sender.tag = 0;
            
            //Change button title to NO
            [sender setTitle:@"NO" forState: UIControlStateNormal];
        }
    }
    //if commitButton is 2 or 3 just animate the button without retrieve gps data
    else if (self.commitButton.tag == 2 || self.commitButton.tag == 3)
    {
        //if button tag is 0 set tag to 1 and change title to YES
        if(sender.tag == 0)
        {
            //Animate button as title changes
            [self animateButton:@"FromBottom"];
            
            //Set button tag to 1
            sender.tag = 1;
            
            //Change button title to YES
            [sender setTitle:@"YES" forState: UIControlStateNormal];
        }
        else
        {
            //Set button tag to 0
            sender.tag = 0;
            
            //Animate button as title changes
            [self animateButton:@"FromTop"];
            
            //Change button title to NO
            [sender setTitle:@"NO" forState: UIControlStateNormal];
        }
    }
}

#pragma mark - GPS Methods and LocationController Delegates

- (void)locationUpdate:(CLLocation *)location
{
    //Store the gps coordinate into gps string
    self.gps = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    //Show alert
    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Unable to retrieve location."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)retrieveGPS
{
    //Remove loading view
    [self.loadingView removeLoadingView];
    
    //Stop locationManager
    [self.locationController.locationManager stopUpdatingLocation];
}

#pragma mark - Saving and Updating Data Methods

- (void)startData
{
    //If required textfields are filled save data
    if(self.filmField.text.length > 0 && self.isoField.text.length > 0 && self.exposureField.text.length > 0 && self.cameraField.text.length > 0){
        NSString *focal = @"";
        NSString *aperture = @"";
        
        //Make sure to get only the numbers from the focallength and aperture fields
        if (self.focalLengthField.text.length > 2 && ![self.focalLengthField.text isEqualToString:@"mm"])
            focal = [self.focalLengthField.text substringToIndex:self.focalLengthField.text.length-2];
        if (self.apertureField.text.length > 2 && ![self.apertureField.text isEqualToString:@"F/"])
            aperture = [self.apertureField.text substringFromIndex:2];
        
        //Get the current data and format it in a string
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM. dd. yyyy"];
        NSString *theDate = [formatter stringFromDate:[NSDate date]];
        
        //Create a formatted string with sqlite command with field values for Roll table
        NSString *rollTable = [NSString stringWithFormat:@"INSERT INTO Roll ('Exposures','FilmName','Iso','Camera','Date') VALUES ('%@','%@','%@','%@','%@');",self.exposureField.text,self.filmField.text,self.isoField.text,self.cameraField.text,theDate];
        
        //Send command to sqlite to insert row into Roll table
        [self.dataController sendSqlData:rollTable whichTable:@"Roll"];
        
        
        //Get the id of the last created roll id
        int rollId = [[self.dataController singleRead:@"SELECT MAX(ID) FROM Roll"] intValue];
        
        //Create a formatted string with sqlite command with field values for Exposure table
        NSString *exposureTable = [NSString stringWithFormat:@"INSERT INTO Exposure ('Exposure', 'Roll_Id','Focal','Aperture','Shutter','Gps','Notes') VALUES ('%d','%d','%@','%@','%@','%@','%@');",1,rollId,focal,aperture,@"",self.gps,@"Notes:"];
        
        //Send command to sqlite to insert row into Exposure table
        [self.dataController sendSqlData:exposureTable whichTable:@"Exposure"];
    
    }
    else
    {
        //If required field were empty show alert
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Roll Not Saved"
                                                        message:@"Roll was not saved because required fields film name, iso, exposure, and camera were not filled out."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        //Dismiss any keyboard on screen
        [self dismissKeyboard];
    }
    
}


- (void)saveData
{
    //Select this preset after it is created
    NSString *isDefault = [NSString stringWithFormat:@"%i",0];
    [[NSUserDefaults standardUserDefaults]
     setObject:isDefault forKey:@"selectedDefault"];
    
    NSString *focal = @"";
    NSString *aperture = @"";
    
    //Store focalLength and ApertureField without "mm" or "F/"
    if (self.focalLengthField.text.length > 2 && ![self.focalLengthField.text isEqualToString:@"mm"])
        focal = [self.focalLengthField.text substringToIndex:self.focalLengthField.text.length-2];
    if (self.apertureField.text.length > 2 && ![self.apertureField.text isEqualToString:@"F/"])
        aperture = [self.apertureField.text substringFromIndex:2];
    
    //Create a formatted string with sqlite command with field values for Defaults table
    NSString *defaultsTable = [NSString stringWithFormat:@"INSERT INTO Defaults ('FilmName','Iso','Exposure','Camera','Focal','Aperture','Gps') VALUES ('%@','%@','%@','%@','%@','%@','%@');",self.filmField.text,self.isoField.text,self.exposureField.text,self.cameraField.text,focal,aperture,self.gpsButton.currentTitle];
    
    //Send sqlite command to insert row in Defaults table
    [self.dataController sendSqlData:defaultsTable whichTable:@"Defaults"];
}

- (void)updateData
{
    //Select this present that is about to be updated
    NSString *isDefault = [NSString stringWithFormat:@"%li",(long)self.rowID];
    [[NSUserDefaults standardUserDefaults]
     setObject:isDefault forKey:@"selectedDefault"];
    
    NSString *focal = @"";
    NSString *aperture = @"";
    
    //Store focalLength and ApertureField without "mm" or "F/"
    if (self.focalLengthField.text.length > 2 && ![self.focalLengthField.text isEqualToString:@"mm"])
        focal = [self.focalLengthField.text substringToIndex:self.focalLengthField.text.length-2];
    if (self.apertureField.text.length > 2 && ![self.apertureField.text isEqualToString:@"F/"])
        aperture = [self.apertureField.text substringFromIndex:2];
    
    //Create a formatted string with sqlite command with field values for Defaults table
    NSString *updateData = [NSString stringWithFormat:@"UPDATE Defaults SET Filmname = '%@', Iso = '%@', Exposure ='%@', Camera = '%@', Focal = '%@', Aperture = '%@', Gps = '%@' WHERE Id = '%ld';",self.filmField.text,self.isoField.text,self.exposureField.text,self.cameraField.text,focal,aperture,self.gpsButton.currentTitle,(long)self.defaultID];
    
    //Send sqlite command to update row in Defaults table
    [self.dataController sendSqlData:updateData whichTable:@"Defaults"];
}

#pragma mark - View Animation and Button Animation Methods

-(void)setViewMovedUp:(BOOL)movedUp
{
    //Get the dimenisons of the view
    CGRect currentFrame = self.view.frame;
    
    //Make sure screen is not iphone 5 size and view is not moved up yet
    if (([UIScreen mainScreen].bounds.size.height == 480) && ((currentFrame.origin.y == rect.origin.y) && movedUp))
    {
        //Animation when moving view up
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
    
        //Shift the y axis of the current dimenisons
        currentFrame.origin.y -= kOFFSET_FOR_KEYBOARD;
        
        //Set the view dimenisons to currentFrame
        self.view.frame = currentFrame;
        
        //Animate
        [UIView commitAnimations];
    }
    //Make sure screen is not iphone 5 size and view has not moved down already
    else if (([UIScreen mainScreen].bounds.size.height == 480) && ((currentFrame.origin.y + kOFFSET_FOR_KEYBOARD == rect.origin.y) && !movedUp))
    {
        //Animation when moving view down
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        //Revert the y axis of the current dimenisons
        currentFrame.origin.y += kOFFSET_FOR_KEYBOARD;
        
        //Set the view dimenisons to currentFrame
        self.view.frame = currentFrame;
        
        //Animate
        [UIView commitAnimations];
    }
}

- (void) animateButton:(NSString*)direction{
    //Instantiate CAtransition
	CATransition *animation = [CATransition animation];
    
    //Set the duration of transition
	[animation setDuration:0.35];
    
    //Set the type of transition
	[animation setType:kCATransitionPush];
    
    //Determine direction of transition based on method parameter
    if ([direction isEqualToString:@"FromBottom"])
        [animation setSubtype:kCATransitionFromBottom];
    else if ([direction isEqualToString:@"FromTop"])
        [animation setSubtype:kCATransitionFromTop];
    
    //Make animation smoother with timing
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    //Add animation to button layer
    [[self.gpsButton layer] addAnimation:animation forKey:direction];
}

#pragma mark - TextField Delegate Methods and DismissKeyboard Method

//Dismiss all keyboards
- (void)dismissKeyboard
{
    [self.filmField resignFirstResponder];
    [self.isoField resignFirstResponder];
    [self.exposureField resignFirstResponder];
    [self.cameraField resignFirstResponder];
    [self.focalLengthField resignFirstResponder];
    [self.apertureField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    //Determine if the textfield is focallength
    if([textField isEqual:self.focalLengthField])
    {
        //If textfield is empty add "mm" and set the cursor in front of it
        if([textField.text isEqualToString:@""])
        {
            textField.text = [NSString stringWithFormat:@"%@mm",textField.text];
            textField.selectedTextRange = [textField
                                           textRangeFromPosition:textField.beginningOfDocument
                                           toPosition:textField.beginningOfDocument];
        }
        //Make sure user isn't able to select the "mm" in the textfield
        else
        {
            UITextPosition *cutOffPositon = [textField positionFromPosition:textField.beginningOfDocument offset:textField.text.length-2];
            textField.selectedTextRange = [textField
                                           textRangeFromPosition:cutOffPositon
                                           toPosition:cutOffPositon];
        }
    }
    //Determine if textfield is aperturefield
    if([textField isEqual:self.apertureField])
    {
        //If textfield is empty add "F/" to the front of it
        if ([textField.text isEqualToString:@""])
            textField.text = @"F/";
    }
    //If textfield are not focallength or aperture field make sure view is not moved up
    if(![textField isEqual:self.focalLengthField] && ![textField isEqual:self.apertureField])
        [self setViewMovedUp:NO];
}

//Custom Textfield Delegate method which moves up view
-(void)moveViewTextField:(UITextField *)textField
{
    if([textField isFirstResponder])
    {
        [self setViewMovedUp:YES];
    }
}

//Custom Textfield Delegate method which moves down view
-(void)dismissMoveViewTextField:(UITextField *)textField
{
    if(![textField isFirstResponder])
    {
        [self setViewMovedUp:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Determine if textfield is aperturefield
    if ([textField isEqual:self.apertureField])
    {
        //Makes sure the textfield does not exceed 6 characters and the next key entered is not backspace
        if((textField.text.length >= 6) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:6];
            [self dismissKeyboard];
        }
        //Makes sure the user cannot enter more then one decimal point
        if (([textField.text rangeOfString:@"." options:NSBackwardsSearch].length != 0) && [string isEqualToString:@"."])
        return NO;
        
        //Gets the position of the beginning of the textfield
        UITextPosition* beginning = textField.beginningOfDocument;
        
        //Gets the selected range of the textfield
        UITextRange* selectedRange = textField.selectedTextRange;
        
        //Gets the starting position of the selection
        UITextPosition* selectionStart = selectedRange.start;
        
        //Gets the ending position of the selection
        UITextPosition* selectionEnd = selectedRange.end;
        
        //Gets the length and location of the selection as NSInteger
        const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
        const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
        
        //Gets the position of the cursor
        NSRange cursorPositon = NSMakeRange(location, length);
        
        //Makes sure the user cannot select "mm" in the textfield
        if((textField.text.length == cursorPositon.length) || (textField.text.length-1 == cursorPositon.length))
        {
            UITextPosition *cutOffPositon = [textField positionFromPosition:beginning offset:2];
            [textField setSelectedTextRange:[textField textRangeFromPosition:cutOffPositon toPosition:selectionEnd]];
        }
        
        //Makes sure the user cannot delete "mm"
        if(((cursorPositon.location <= 2 && [string isEqualToString:@""]) || cursorPositon.location < 2) && cursorPositon.length < 1)
            return NO;
    }
    //Determine if textfield is focalLength
    if ([textField isEqual:self.focalLengthField])
    {
        //Makes sure the textfield does not exceed 6 characters and the next key entered is not backspace
        if((textField.text.length >= 6) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:6];
            [self performSelector:@selector(dismissKeyboard)];
        }
        
        //Gets the position of the beginning of the textfield
        UITextPosition* beginning = textField.beginningOfDocument;
        
        //Gets the selected range of the textfield
        UITextRange* selectedRange = textField.selectedTextRange;
        
        //Gets the starting position of the selection
        UITextPosition* selectionStart = selectedRange.start;
        
        //Gets the ending position of the selection
        UITextPosition* selectionEnd = selectedRange.end;
        
        //Gets the length and location of the selection as NSInteger
        const NSInteger location = [textField offsetFromPosition:beginning toPosition:selectionStart];
        const NSInteger length = [textField offsetFromPosition:selectionStart toPosition:selectionEnd];
        
        //Gets the position of the cursor
        NSRange cursorPositon = NSMakeRange(location, length);
        
        //Makes sure the user cannot select "F/" in the textfield
        if((textField.text.length == cursorPositon.length) || (textField.text.length-1 == cursorPositon.length))
        {
            UITextPosition *cutOffPositon = [textField positionFromPosition:selectionStart offset:textField.text.length-2];
            [textField setSelectedTextRange:[textField textRangeFromPosition:selectionStart toPosition:cutOffPositon]];
        }
        
        //Makes sure the user cannot delete "F/"
        if(cursorPositon.location > textField.text.length - 2)
            return NO;
    }
    
    //Makes sure the textfields filmField and cameraField do not exceed 12 characters
    if (([textField isEqual:self.filmField] || [textField isEqual:self.cameraField]) && ![string isEqualToString:@""])
        if((textField.text.length >= 12)){
            textField.text = [textField.text substringToIndex:12];
            [self performSelector:@selector(dismissKeyboard)];
        }
    //Makes sure the textfield isoField do not exceed 4 characters
    if ([textField isEqual:self.isoField] && ![string isEqualToString:@""])
        if((textField.text.length >= 4)){
            textField.text = [textField.text substringToIndex:4];
            [self performSelector:@selector(dismissKeyboard)];
        }
    //Makes sure the textfield exposureField do not exceed 2 characters
    if ([textField isEqual:self.exposureField] && ![string isEqualToString:@""])
        if((textField.text.length >= 2)){
            textField.text = [textField.text substringToIndex:2];
            [self performSelector:@selector(dismissKeyboard)];
        }
    
    return YES;
}

#pragma mark - Gesture Handling
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    //Dismisses the current view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Set object delegates and allocate locationController
    self.focalLengthField.delegate = self;
    self.apertureField.delegate = self;
    self.locationController = [[LocationController alloc] init];
	self.locationController.delegate = self;
    
    //Instaniate Swipe Gesture from down direction
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];
    
    //Instaniate Tap Gesture so when user taps outside textfield it dismisses any keyboard on screen
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Instances of UIFont and UIColor
    UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:24];
    UIColor *fontColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    
    //Sets titleLabel textcolor and font
    self.titleLabel.textColor = [UIColor redColor];
    self.titleLabel.font = [UIFont systemFontOfSize:28];
    
    //Sets gpsButton font, text alignment, title color, title, and tag
    self.gpsButton.titleLabel.font = generalFont;
    self.gpsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.gpsButton setTitleColor:fontColor forState:UIControlStateNormal];
    [self.gpsButton setTitle:@"NO" forState: UIControlStateNormal];
    self.gpsButton.tag = 0;
    
    //Set filmField text color, alignment, font, and placeholder
    self.filmField.textColor = fontColor;
    self.filmField.textAlignment = NSTextAlignmentLeft;
    self.filmField.font = generalFont;
    self.filmField.placeholder = @"Fuji Astia";
    
    //Set isoField text color, alignment, font, and placeholder
    self.isoField.textColor = fontColor;
    self.isoField.textAlignment = NSTextAlignmentLeft;
    self.isoField.font = generalFont;
    self.isoField.placeholder = @"100";
    
    //Set exposureField text color, alignment, font, and placeholder
    self.exposureField.textColor = fontColor;
    self.exposureField.textAlignment = NSTextAlignmentLeft;
    self.exposureField.font = generalFont;
    self.exposureField.placeholder = @"36";
    
    //Set cameraField text color, alignment, font, and placeholder
    self.cameraField.textColor = fontColor;
    self.cameraField.textAlignment = NSTextAlignmentLeft;
    self.cameraField.font = generalFont;
    self.cameraField.placeholder = @"Leica M6";
    
    //Set focalLength text color, alignment, font, and placeholder
    self.focalLengthField.textColor = fontColor;
    self.focalLengthField.textAlignment = NSTextAlignmentLeft;
    self.focalLengthField.font = generalFont;
    self.focalLengthField.placeholder = @"50mm";
    
    //Set apertureField text color, alignment, font, and placeholder
    self.apertureField.textColor = fontColor;
    self.apertureField.textAlignment = NSTextAlignmentLeft;
    self.apertureField.font = generalFont;
    self.apertureField.placeholder = @"F/0.95";
    
    //Set gps string to No GPS as default
    self.gps = @"No GPS";
    
    //Sets commitButton font, text alignment, title color, title, and tag
    self.commitButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    self.commitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.commitButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:48];
    [self.commitButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    
    self.commitButton.tag = self.commitTag;
    
    if (self.commitButton.tag == 1)
    {
        NSString *theDefault = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"theDefault"];
        self.data = [self.dataController readTable:[NSString stringWithFormat:@"SELECT * FROM Defaults WHERE id = '%@'",theDefault]];
        
        if (self.data.count != 0)
        {
            if(!([[[self.data objectAtIndex:0] objectAtIndex:1] isEqualToString:@""]))
                self.filmField.text = [[self.data objectAtIndex:0] objectAtIndex:1];
            if(!([[[self.data objectAtIndex:0] objectAtIndex:2] isEqualToString:@""]))
                self.isoField.text = [[self.data objectAtIndex:0] objectAtIndex:2];
            if(!([[[self.data objectAtIndex:0] objectAtIndex:3] isEqualToString:@""]))
                self.exposureField.text = [[self.data objectAtIndex:0] objectAtIndex:3];
            if(!([[[self.data objectAtIndex:0] objectAtIndex:4] isEqualToString:@""]))
                self.cameraField.text = [[self.data objectAtIndex:0] objectAtIndex:4];
            if(!([[[data objectAtIndex:0] objectAtIndex:5] isEqualToString:@""]))
                self.focalLengthField.text = [NSString stringWithFormat:@"%@mm",[[self.data objectAtIndex:0] objectAtIndex:5]];
            if(!([[[self.data objectAtIndex:0] objectAtIndex:6] isEqualToString:@""]))
                self.apertureField.text = [NSString stringWithFormat:@"F/%@",[[self.data objectAtIndex:0] objectAtIndex:6]];
        }
        
        self.titleLabel.text = @"New Roll:";
        [self.commitButton setTitle:@"Start" forState: UIControlStateNormal];
    }
    else if (self.commitButton.tag == 2)
    {
        self.titleLabel.text = @"Add Preset:";
        [self.commitButton setTitle:@"Save" forState: UIControlStateNormal];
    }else if (self.commitButton.tag == 3)
    {
        self.data = [self.dataController readTable:@"SELECT * FROM Defaults"];
        
        self.defaultID = [[[self.data objectAtIndex:(self.data.count - self.rowID - 1)] objectAtIndex:0] integerValue];
        NSString *rowData = [NSString stringWithFormat:@"SELECT * FROM Defaults WHERE id = %ld", (long)self.defaultID];
        self.data = [self.dataController readTable:rowData];
        self.filmField.text = [[self.data objectAtIndex:0] objectAtIndex:1];
        self.isoField.text = [[self.data objectAtIndex:0] objectAtIndex:2];
        self.exposureField.text = [[self.data objectAtIndex:0] objectAtIndex:3];
        self.cameraField.text = [[self.data objectAtIndex:0] objectAtIndex:4];
        if (![[[self.data objectAtIndex:0] objectAtIndex:5] isEqualToString:@""])
            self.focalLengthField.text = [NSString stringWithFormat:@"%@mm",[[self.data objectAtIndex:0] objectAtIndex:5]];
        if (![[[self.data objectAtIndex:0] objectAtIndex:6] isEqualToString:@""])
            self.apertureField.text = [NSString stringWithFormat:@"F/%@",[[data objectAtIndex:0] objectAtIndex:6]];
        if([[[self.data objectAtIndex:0] objectAtIndex:7] isEqualToString:@"YES"])
        {
            [self.gpsButton setTitle:@"YES" forState: UIControlStateNormal];
            self.gpsButton.tag = 1;
        }
        else
        {
            [self.gpsButton setTitle:@"NO" forState: UIControlStateNormal];
            self.gpsButton.tag = 0;
        }
        
        self.titleLabel.text = @"Update Preset:";
        [self.commitButton setTitle:@"Update" forState: UIControlStateNormal];
    }
    self.rect = self.view.frame;
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.commitButton.tag == 1)
    {
        if(self.data.count != 0)
            if([[[self.data objectAtIndex:0] objectAtIndex:7] isEqualToString:@"YES"])
            {
                //[self.gpsButton setTitle:@"NO" forState:UIControlStateNormal];
                self.gpsButton.tag = 0;
                [self performSelector:@selector(gpsButtonPressed:) withObject:gpsButton];
            }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - Prep for Segue 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RollDataInfo"] && self.commitButton.tag == 1) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Start to begin.\n\nSwipe down to exit.";
    }
    if ([segue.identifier isEqualToString:@"RollDataInfo"] && self.commitButton.tag == 2) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on save to add preset.\n\nSwipe down to cancel.";
    }
    if ([segue.identifier isEqualToString:@"RollDataInfo"] && self.commitButton.tag == 3) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Update to update the presets.\n\nSwipe down to cancel.";
    }
}

#pragma mark Memory Warning Method 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
