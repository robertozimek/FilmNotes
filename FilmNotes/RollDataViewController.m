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

-(DatabaseControl *)dataController
{
    if (!_dataController) _dataController = [[DatabaseControl alloc] init];
    return _dataController;
}

- (IBAction)gpsButtonPressed:(UIButton *)sender {
    if(self.commitButton.tag == 1)
    {
        [self dismissKeyboard];
        if(sender.tag == 0)
        {
            [self.locationController.locationManager startUpdatingLocation];
            BOOL loop = YES;
            while (loop)
            {
                if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
                {
                    loop = NO;
                    self.loadingView = [LoadingView loadLoadingViewIntoView:self.view];
                    [self performSelector:@selector(retrieveGPS) withObject:nil afterDelay:1.0];
                    [self animateButton:@"FromBottom"];
                    sender.tag = 1;
                    [sender setTitle:@"YES" forState: UIControlStateNormal];
                }else if ([self.locationController.locationServicesStatus isEqualToString:@"restricted"])
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
        else
        {
            [self animateButton:@"FromTop"];
            self.gps = @"No GPS";
            sender.tag = 0;
            [sender setTitle:@"NO" forState: UIControlStateNormal];
        }
    }
    else if (self.commitButton.tag == 2 || self.commitButton.tag == 3)
    {
        if(sender.tag == 0)
        {
            [self animateButton:@"FromBottom"];
            sender.tag = 1;
            [sender setTitle:@"YES" forState: UIControlStateNormal];
        }
        else
        {
            sender.tag = 0;
            [self animateButton:@"FromTop"];
            [sender setTitle:@"NO" forState: UIControlStateNormal];
        }
    }
}


- (void)locationUpdate:(CLLocation *)location
{
    self.gps = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    self.gps = @"";
}

-(void)retrieveGPS
{
    [self.loadingView removeLoadingView];
    [self.locationController.locationManager stopUpdatingLocation];
}

- (void)startData
{
    if(self.filmField.text.length > 0 && self.isoField.text.length > 0 && self.exposureField.text.length > 0 && self.cameraField.text.length > 0){
        NSString *focal = @"";
        NSString *aperture = @"";
        if (self.focalLengthField.text.length > 2 && ![self.focalLengthField.text isEqualToString:@"mm"])
            focal = [self.focalLengthField.text substringToIndex:self.focalLengthField.text.length-2];
        if (self.apertureField.text.length > 2 && ![self.apertureField.text isEqualToString:@"F/"])
            aperture = [self.apertureField.text substringFromIndex:2];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM. dd. yyyy"];
        NSString *theDate = [formatter stringFromDate:[NSDate date]];
        NSLog(@"GPS: %@",self.gps);
        
        NSString *rollTable = [NSString stringWithFormat:@"INSERT INTO Roll ('ExposureId','FilmName','Iso','Camera','Date') VALUES ('%@','%@','%@','%@','%@');",self.exposureField.text,self.filmField.text,self.isoField.text,self.cameraField.text,theDate];
        
        [self.dataController sendSqlData:rollTable whichTable:@"Roll"];
        
        int rollId = [[self.dataController singleRead:@"SELECT MAX(ID) FROM Roll"] intValue];
        NSString *exposureTable = [NSString stringWithFormat:@"INSERT INTO Exposure ('Id', 'Roll_Id','Exposure_Id','Focal','Aperture','Shutter','Gps','Notes') VALUES ('%d','%d','%@','%@','%@','%@','%@','%@');",1,rollId,self.exposureField.text,focal,aperture,@"",self.gps,@"Notes:"];
        [self.dataController sendSqlData:exposureTable whichTable:@"Exposure"];
    
    }
    else
    {
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Roll Not Saved"
                                                        message:@"Roll was not saved because required fields film name, iso, exposure, and camera were not filled out."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self dismissKeyboard];
    }
    
}


- (void)saveData
{
    NSString *isDefault = [NSString stringWithFormat:@"%i",0];
    [[NSUserDefaults standardUserDefaults]
     setObject:isDefault forKey:@"selectedDefault"];
    
    NSString *focal = @"";
    NSString *aperture = @"";
    if (self.focalLengthField.text.length > 2 && ![self.focalLengthField.text isEqualToString:@"mm"])
        focal = [self.focalLengthField.text substringToIndex:self.focalLengthField.text.length-2];
    if (self.apertureField.text.length > 2 && ![self.apertureField.text isEqualToString:@"F/"])
        aperture = [self.apertureField.text substringFromIndex:2];
    
    NSString *defaultsTable = [NSString stringWithFormat:@"INSERT INTO Defaults ('FilmName','Iso','Exposure','Camera','Focal','Aperture','Gps') VALUES ('%@','%@','%@','%@','%@','%@','%@');",self.filmField.text,self.isoField.text,self.exposureField.text,self.cameraField.text,focal,aperture,self.gpsButton.currentTitle];
    [self.dataController sendSqlData:defaultsTable whichTable:@"Defaults"];
}

- (void)updateData
{
    NSString *isDefault = [NSString stringWithFormat:@"%i",self.rowID];
    [[NSUserDefaults standardUserDefaults]
     setObject:isDefault forKey:@"selectedDefault"];
    NSString *focal = @"";
    NSString *aperture = @"";
    if (self.focalLengthField.text.length > 2 && ![self.focalLengthField.text isEqualToString:@"mm"])
        focal = [self.focalLengthField.text substringToIndex:self.focalLengthField.text.length-2];
    if (self.apertureField.text.length > 2 && ![self.apertureField.text isEqualToString:@"F/"])
        aperture = [self.apertureField.text substringFromIndex:2];
    
    NSString *updateData = [NSString stringWithFormat:@"UPDATE Defaults SET Filmname = '%@', Iso = '%@', Exposure ='%@', Camera = '%@', Focal = '%@', Aperture = '%@', Gps = '%@' WHERE Id = '%d';",self.filmField.text,self.isoField.text,self.exposureField.text,self.cameraField.text,focal,aperture,self.gpsButton.currentTitle,self.defaultID];
    [self.dataController sendSqlData:updateData whichTable:@"Defaults"];
}

- (IBAction)commitButtonPressed:(UIButton *)sender {
    if(sender.tag == 1)
        [self startData];
    else if (sender.tag == 2 || sender.tag == 3)
    {
        if ((![self.filmField.text isEqualToString:@""] && ![self.isoField.text isEqualToString:@""] && ![self.cameraField.text isEqualToString:@""]) || ![self.exposureField.text isEqualToString:@""] || !([self.focalLengthField.text isEqualToString:@""] || [self.focalLengthField.text isEqualToString:@"mm"]) || !([self.apertureField.text isEqualToString:@""] || [self.apertureField.text isEqualToString:@"F/"]))
        {
            if(self.commitButton.tag == 3)
                [self updateData];
            else
                [self saveData];
        }else
        {
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Roll Not Saved"
                                                            message:@"Roll was not saved because required fields film, iso,camera are empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.focalLengthField.delegate = self;
    self.apertureField.delegate = self;
    self.locationController = [[LocationController alloc] init];
	self.locationController.delegate = self;
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:24];
    UIColor *fontColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    
    self.titleLabel.textColor = [UIColor redColor];
    self.titleLabel.font = [UIFont systemFontOfSize:28];
    
    self.gpsButton.titleLabel.font = generalFont;
    self.gpsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.gpsButton setTitleColor:fontColor forState:UIControlStateNormal];
    [self.gpsButton setTitle:@"NO" forState: UIControlStateNormal];
    self.gpsButton.tag = 0;
    
    self.filmField.textColor = fontColor;
    self.filmField.textAlignment = NSTextAlignmentLeft;
    self.filmField.font = generalFont;
    self.filmField.placeholder = @"Fuji Astia";
    
    self.isoField.textColor = fontColor;
    self.isoField.textAlignment = NSTextAlignmentLeft;
    self.isoField.font = generalFont;
    self.isoField.placeholder = @"100";
        
    self.exposureField.textColor = fontColor;
    self.exposureField.textAlignment = NSTextAlignmentLeft;
    self.exposureField.font = generalFont;
    self.exposureField.placeholder = @"36";
    
    self.cameraField.textColor = fontColor;
    self.cameraField.textAlignment = NSTextAlignmentLeft;
    self.cameraField.font = generalFont;
    self.cameraField.placeholder = @"Leica M6";
        
    self.focalLengthField.textColor = fontColor;
    self.focalLengthField.textAlignment = NSTextAlignmentLeft;
    self.focalLengthField.font = generalFont;
    self.focalLengthField.placeholder = @"50mm";
    
    self.apertureField.textColor = fontColor;
    self.apertureField.textAlignment = NSTextAlignmentLeft;
    self.apertureField.font = generalFont;
    self.apertureField.placeholder = @"F/0.95";
    
    self.gps = @"No GPS";
    
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
        NSString *rowData = [NSString stringWithFormat:@"SELECT * FROM Defaults WHERE id = %d", self.defaultID];
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

- (void)dismissKeyboard
{
    [self.filmField resignFirstResponder];
    [self.isoField resignFirstResponder];
    [self.exposureField resignFirstResponder];
    [self.cameraField resignFirstResponder];
    [self.focalLengthField resignFirstResponder];
    [self.apertureField resignFirstResponder];
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    CGRect currentFrame = self.view.frame;
    if (([UIScreen mainScreen].bounds.size.height == 480) && ((currentFrame.origin.y == rect.origin.y) && movedUp))
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        currentFrame.origin.y -= kOFFSET_FOR_KEYBOARD;
        
        self.view.frame = currentFrame;
        [UIView commitAnimations];
    }
    else if (([UIScreen mainScreen].bounds.size.height == 480) && ((currentFrame.origin.y + kOFFSET_FOR_KEYBOARD == rect.origin.y) && !movedUp))
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        
        // revert back to the normal state.
        currentFrame.origin.y += kOFFSET_FOR_KEYBOARD;
        
        self.view.frame = currentFrame;
        [UIView commitAnimations];
    }
}

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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual:self.focalLengthField])
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
    if([textField isEqual:self.apertureField])
    {
        if ([textField.text isEqualToString:@""])
        textField.text = @"F/";
    }
    if(![textField isEqual:self.focalLengthField] && ![textField isEqual:self.apertureField])
        [self setViewMovedUp:NO];
}

-(void)moveViewTextField:(UITextField *)textField
{
    if([textField isFirstResponder])
    {
        [self setViewMovedUp:YES];
    }
}

-(void)dismissMoveViewTextField:(UITextField *)textField
{
    if(![textField isFirstResponder])
    {
        [self setViewMovedUp:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.apertureField])
    {
        if((textField.text.length >= 6) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:6];
            [self performSelector:@selector(dismissKeyboard)];
        }
        if (([textField.text rangeOfString:@"." options:NSBackwardsSearch].length != 0) && [string isEqualToString:@"."])
        return NO;
        
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
    if ([textField isEqual:self.focalLengthField])
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
    
    
    if (([textField isEqual:self.filmField] || [textField isEqual:self.cameraField]) && ![string isEqualToString:@""])
        if((textField.text.length >= 12)){
            textField.text = [textField.text substringToIndex:12];
            [self performSelector:@selector(dismissKeyboard)];
        }
    if ([textField isEqual:self.isoField] && ![string isEqualToString:@""])
        if((textField.text.length >= 4)){
            textField.text = [textField.text substringToIndex:4];
            [self performSelector:@selector(dismissKeyboard)];
        }
    if ([textField isEqual:self.exposureField] && ![string isEqualToString:@""])
        if((textField.text.length >= 2)){
            textField.text = [textField.text substringToIndex:2];
            [self performSelector:@selector(dismissKeyboard)];
        }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RollDataInfo"] && self.commitButton.tag == 1) {
            MoreInfoViewController *moreViewController = segue.destinationViewController;
            moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Start to begin.\n\nSwipe Down to go cancel the new roll.\n\nSwipe down to exit.";
        }
    if ([segue.identifier isEqualToString:@"RollDataInfo"] && self.commitButton.tag == 2) {
            MoreInfoViewController *moreViewController = segue.destinationViewController;
            moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on save to add preset.\n\nSwipe Down to go cancel.";
        }
    if ([segue.identifier isEqualToString:@"RollDataInfo"] && self.commitButton.tag == 3) {
            MoreInfoViewController *moreViewController = segue.destinationViewController;
            moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Update to update the presets.\n\nSwipe Down to cancel.";
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
