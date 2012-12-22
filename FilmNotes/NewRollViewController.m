//
//  NewRollViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/30/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "NewRollViewController.h"
#import "DatabaseControl.h"
#import "MoreInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h> 
#import "TTAlertView.h"
#import "LoadingView.h"

@interface NewRollViewController ()
@property (strong, nonatomic) LoadingView *loadingView;
@property (strong, nonatomic) DatabaseControl *dataController;
@property (strong, nonatomic) LocationController *locationController;
@property (strong, nonatomic) NSString *gps;
@property (strong, nonatomic) NSArray *data;
@end

@implementation NewRollViewController
#define kOFFSET_FOR_KEYBOARD 80.0
@synthesize filmField;
@synthesize isoField;
@synthesize exposureField;
@synthesize cameraField;
@synthesize focalLengthField;
@synthesize apertureField;
@synthesize gpsButton;
@synthesize startButton;
@synthesize locationController;
@synthesize loadingView;
@synthesize gps;
@synthesize data;
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
    if([sender.currentTitle isEqualToString:@"NO"])
    {
        [self.locationController.locationManager startUpdatingLocation];
        if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
        {
            loadingView = [LoadingView loadLoadingViewIntoView:self.view];
            [self performSelector:@selector(retrieveGPS) withObject:nil afterDelay:1.0];
        }else
        {
            BOOL loop = YES;
            while (loop)
            {
                if ([self.locationController.locationServicesStatus isEqualToString:@"authorized"])
                {
                    loop = NO;
                    loadingView = [LoadingView loadLoadingViewIntoView:self.view];
                    [self performSelector:@selector(retrieveGPS) withObject:nil afterDelay:1.0];
                }
            }
            
        }
        [self animateButton:@"FromBottom"];
        [sender setTitle:@"YES" forState: UIControlStateNormal];
    }
    else
    {
        
        [self animateButton:@"FromTop"];
        gps = @"No GPS";
        [sender setTitle:@"NO" forState: UIControlStateNormal];
    }
}


- (void)locationUpdate:(CLLocation *)location
{
    gps = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    
}

-(void) retrieveGPS
{
    [loadingView removeLoadingView];
    [self.locationController.locationManager stopUpdatingLocation];
}

- (void)saveData
{
    if(filmField.text.length > 0 && isoField.text.length > 0 && exposureField.text.length > 0 && cameraField.text.length > 0){
        NSString *focal = @"";
        NSString *aperture = @"";
        if (focalLengthField.text.length > 2)
            focal = [focalLengthField.text substringToIndex:focalLengthField.text.length-2];
        if (apertureField.text.length > 2)
            aperture = [apertureField.text substringFromIndex:2];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM. dd. yyyy"];
        NSString *theDate = [formatter stringFromDate:[NSDate date]];
        NSLog(@"GPS: %@",gps);
        
        NSString *rollTable = [NSString stringWithFormat:@"INSERT INTO Roll ('ExposureId','FilmName','Iso','Camera','Date') VALUES ('%@','%@','%@','%@','%@');",exposureField.text,filmField.text,isoField.text,cameraField.text,theDate];
        
        [self.dataController sendSqlData:rollTable whichTable:@"Roll"];
        
        int rollId = [[self.dataController singleRead:@"SELECT MAX(ID) FROM Roll"] intValue];
        NSString *exposureTable = [NSString stringWithFormat:@"INSERT INTO Exposure ('Id', 'Roll_Id','Exposure_Id','Focal','Aperture','Shutter','Gps','Notes') VALUES ('%d','%d','%@','%@','%@','%@','%@','%@');",1,rollId,exposureField.text,focal,aperture,@"",gps,@"Notes:"];
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
- (IBAction)startButton:(id)sender {
    [self saveData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationController = [[LocationController alloc] init];
	locationController.delegate = self;
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    NSString *theDefault = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"theDefault"];
    NSLog(@"theDefault: %@",theDefault);
    data = [self.dataController readTable:[NSString stringWithFormat:@"SELECT * FROM Defaults WHERE id = '%@'",theDefault]];
    
    UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:24];
    UIColor *fontColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    gpsButton.titleLabel.font = generalFont;
    gpsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [gpsButton setTitleColor:fontColor forState:UIControlStateNormal];
    [gpsButton setTitle:@"NO" forState: UIControlStateNormal];
    
    filmField.textColor = fontColor;
    filmField.textAlignment = NSTextAlignmentLeft;
    filmField.font = generalFont;
    filmField.placeholder = @"Fuji Astia";
    filmField.clearsOnBeginEditing = YES;
    
    isoField.textColor = fontColor;
    isoField.textAlignment = NSTextAlignmentLeft;
    isoField.font = generalFont;
    isoField.placeholder = @"100";
    isoField.clearsOnBeginEditing = YES;
        
    exposureField.textColor = fontColor;
    exposureField.textAlignment = NSTextAlignmentLeft;
    exposureField.font = generalFont;
    exposureField.placeholder = @"36";
    exposureField.clearsOnBeginEditing = YES;
    
    cameraField.textColor = fontColor;
    cameraField.textAlignment = NSTextAlignmentLeft;
    cameraField.font = generalFont;
    cameraField.placeholder = @"Leica M6";
    cameraField.clearsOnBeginEditing = YES;
        
    focalLengthField.textColor = fontColor;
    focalLengthField.textAlignment = NSTextAlignmentLeft;
    focalLengthField.font = generalFont;
    focalLengthField.placeholder = @"50mm";
    focalLengthField.clearsOnBeginEditing = YES;
    
    apertureField.textColor = fontColor;
    apertureField.textAlignment = NSTextAlignmentLeft;
    apertureField.font = generalFont;
    apertureField.placeholder = @"F/0.95";
    
    gps = @"No GPS";
    
    if (data.count != 0)
    {
        if(!([[[data objectAtIndex:0] objectAtIndex:1] isEqualToString:@""]))
            filmField.text = [[data objectAtIndex:0] objectAtIndex:1];
        if(!([[[data objectAtIndex:0] objectAtIndex:2] isEqualToString:@""]))
            isoField.text = [[data objectAtIndex:0] objectAtIndex:2];
        if(!([[[data objectAtIndex:0] objectAtIndex:3] isEqualToString:@""]))
            exposureField.text = [[data objectAtIndex:0] objectAtIndex:3];
        if(!([[[data objectAtIndex:0] objectAtIndex:4] isEqualToString:@""]))
            cameraField.text = [[data objectAtIndex:0] objectAtIndex:4];
        if(!([[[data objectAtIndex:0] objectAtIndex:5] isEqualToString:@""]))
            focalLengthField.text = [NSString stringWithFormat:@"%@mm",[[data objectAtIndex:0] objectAtIndex:5]];
        if(!([[[data objectAtIndex:0] objectAtIndex:6] isEqualToString:@""]))
            apertureField.text = [NSString stringWithFormat:@"F/%@",[[data objectAtIndex:0] objectAtIndex:6]];
    }
    
    startButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    startButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:48];
    [startButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    [startButton setTitle:@"Start" forState: UIControlStateNormal];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if(data.count != 0)
        if([[[data objectAtIndex:0] objectAtIndex:7] isEqualToString:@"YES"])
        {
            [gpsButton setTitle:@"NO" forState:UIControlStateNormal];
            [self performSelector:@selector(gpsButtonPressed:) withObject:gpsButton];
        }
}

- (void)dismissKeyboard
{
    [filmField resignFirstResponder];
    [isoField resignFirstResponder];
    [exposureField resignFirstResponder];
    [cameraField resignFirstResponder];
    [focalLengthField resignFirstResponder];
    [apertureField resignFirstResponder];
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual:focalLengthField])
    {
        [self setViewMovedUp:YES];
        textField.text = @"mm";
        textField.selectedTextRange = [textField
                                   textRangeFromPosition:textField.beginningOfDocument
                                   toPosition:textField.beginningOfDocument];
    }
    if([textField isEqual:apertureField])
    {
        [self setViewMovedUp:YES];
        textField.text = @"F/";
    }
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (data.count != 0)
    {
        if([textField isEqual:filmField] && !([[[data objectAtIndex:0] objectAtIndex:2] isEqualToString:@""]) && [filmField.text isEqualToString:@""])
            textField.text = [[data objectAtIndex:0] objectAtIndex:2];
        if([textField isEqual:isoField] && !([[[data objectAtIndex:0] objectAtIndex:3] isEqualToString:@""]) && [isoField.text isEqualToString:@""])
            textField.text = [[data objectAtIndex:0] objectAtIndex:3];
        if([textField isEqual:exposureField] && !([[[data objectAtIndex:0] objectAtIndex:4] isEqualToString:@""]) && [exposureField.text isEqualToString:@""])
            textField.text = [[data objectAtIndex:0] objectAtIndex:4];
        if([textField isEqual:cameraField] && !([[[data objectAtIndex:0] objectAtIndex:5] isEqualToString:@""]) && [cameraField.text isEqualToString:@""])
            textField.text = [[data objectAtIndex:0] objectAtIndex:5];
        if([textField isEqual:focalLengthField] && !([[[data objectAtIndex:0] objectAtIndex:6] isEqualToString:@""]) && ([focalLengthField.text isEqualToString:@""] || [focalLengthField.text isEqualToString:@"mm"]))
            textField.text = [[data objectAtIndex:0] objectAtIndex:6];
        if([textField isEqual:apertureField] && !([[[data objectAtIndex:0] objectAtIndex:7] isEqualToString:@""]) &&([apertureField.text isEqualToString:@""] || [apertureField.text isEqualToString:@"F/"]))
            textField.text = [[data objectAtIndex:0] objectAtIndex:7];
    }
    if([textField isEqual:focalLengthField] || [textField isEqual:apertureField])
        [self setViewMovedUp:NO];
       
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:apertureField])
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
    if ([textField isEqual:focalLengthField])
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
    
    if ([textField isEqual:filmField] || [textField isEqual:cameraField])
        if((textField.text.length >= 12)){
            textField.text = [textField.text substringToIndex:12];
            [self performSelector:@selector(dismissKeyboard)];
        }
    if ([textField isEqual:isoField])
        if((textField.text.length >= 4)){
            textField.text = [textField.text substringToIndex:4];
            [self performSelector:@selector(dismissKeyboard)];
        }
    if ([textField isEqual:exposureField])
        if((textField.text.length >= 2)){
            textField.text = [textField.text substringToIndex:2];
            [self performSelector:@selector(dismissKeyboard)];
        }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NewRollInfo"]) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Start to begin.\n\nSwipe Down to go cancel the new roll.\n\n\n\n\n\n";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
