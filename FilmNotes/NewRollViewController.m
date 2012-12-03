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

@interface NewRollViewController ()
@property (strong, nonatomic) DatabaseControl *dataController;
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

- (IBAction)saveData
{
    if(filmField.text.length > 0 && isoField.text.length > 0 && exposureField.text.length > 0 && cameraField.text.length > 0 && focalLengthField.text.length > 2 && apertureField.text.length > 2){
        NSString *film = filmField.text;
        int iso = [isoField.text intValue];
        int exposure = [exposureField.text intValue];
        NSString *camera = cameraField.text;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM. dd. yyyy"];
        NSString *theDate = [formatter stringFromDate:[NSDate date]];
        
        int focal = [[focalLengthField.text substringToIndex:focalLengthField.text.length-2] intValue];
        double aperture = [[apertureField.text substringFromIndex:2] doubleValue];
        NSString *gps = [gpsButton currentTitle];
        

        NSString *rollTable = [NSString stringWithFormat:@"INSERT INTO Roll ('ExposureId','FilmName','Iso','Camera','Date') VALUES ('%d','%@','%d','%@','%@');",exposure,film,iso,camera,theDate];
        
        [self.dataController sendSqlData:rollTable whichTable:@"Roll"];
        
        int rollId = [[self.dataController singleRead:@"SELECT MAX(ID) FROM Roll"] intValue];
        NSString *exposureTable = [NSString stringWithFormat:@"INSERT INTO Exposure ('Id', 'Roll_Id','Exposure_Id','Focal','Aperture','Shutter','Gps') VALUES ('%d','%d','%d','%d','%f','%@','%@');",1,rollId,exposure,focal,aperture,@"",gps];
        [self.dataController sendSqlData:exposureTable whichTable:@"Exposure"];
        
        filmField.text = @"";
        isoField.text = @"";
        exposureField.text = @"";
        cameraField.text = @"";
        focalLengthField.text = @"";
        apertureField.text = @"";
    }
    else
    {
        NSLog(@"empty filmField");
    }
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self saveData];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:24];
    UIColor *fontColor = [UIColor whiteColor];
    gpsButton.titleLabel.font = generalFont;
    gpsButton.titleLabel.textColor = fontColor;
    [gpsButton setTitle:@"NO" forState: UIControlStateNormal];
    
    
    filmField.textColor = fontColor;
    filmField.textAlignment = NSTextAlignmentLeft;
    filmField.font = generalFont;
    filmField.placeholder = @"Kodak T-Max";
    filmField.clearsOnBeginEditing = YES;
    
    isoField.textColor = fontColor;
    isoField.textAlignment = NSTextAlignmentLeft;
    isoField.font = generalFont;
    isoField.placeholder = @"1600";
    isoField.clearsOnBeginEditing = YES;
    
    exposureField.textColor = fontColor;
    exposureField.textAlignment = NSTextAlignmentLeft;
    exposureField.font = generalFont;
    exposureField.placeholder = @"24";
    exposureField.clearsOnBeginEditing = YES;
    
    cameraField.textColor = fontColor;
    cameraField.textAlignment = NSTextAlignmentLeft;
    cameraField.font = generalFont;
    cameraField.placeholder = @"Canonet 28";
    cameraField.clearsOnBeginEditing = YES;
    
    focalLengthField.textColor = fontColor;
    focalLengthField.textAlignment = NSTextAlignmentLeft;
    focalLengthField.font = generalFont;
    focalLengthField.placeholder = @"40mm";
    focalLengthField.clearsOnBeginEditing = YES;
    
    apertureField.textColor = fontColor;
    apertureField.textAlignment = NSTextAlignmentLeft;
    apertureField.font = generalFont;
    apertureField.placeholder = @"F/2.8";
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
- (IBAction)isoEditingChanged:(id)sender {
    if((isoField.text.length >= 4)){
        isoField.text = [isoField.text substringToIndex:4];
        [self performSelector:@selector(dismissKeyboard)];
    }
}
- (IBAction)exposureEditingChanged:(id)sender {
    if((exposureField.text.length >= 2)){
        exposureField.text = [exposureField.text substringToIndex:2];
        [self performSelector:@selector(dismissKeyboard)];
    }
}

- (IBAction)moveUpTextField:(id)sender {
    [self setViewMovedUp:YES];
}
- (IBAction)moveDownTextFIeld:(id)sender {
    [self setViewMovedUp:NO];
}
- (IBAction)aperatureEditingDidBegin:(id)sender {
    apertureField.text = @"F/";
}
- (IBAction)focalLengthEditingDidBegin:(id)sender {
    focalLengthField.text = @"mm";
}
- (IBAction)focalLengthEditingChanged:(id)sender {
    if((focalLengthField.text.length >= 6)){
        focalLengthField.text = [focalLengthField.text substringToIndex:6];
        [self performSelector:@selector(dismissKeyboard)];
    }
}
- (IBAction)aperatureEditingChanged:(id)sender {
    if((apertureField.text.length >= 6)){
        apertureField.text = [apertureField.text substringToIndex:6];
        [self performSelector:@selector(dismissKeyboard)];
    }
}
- (IBAction)gpsButtonPressed:(UIButton *)sender {
    if([sender.currentTitle isEqualToString:@"NO"])
        [gpsButton setTitle:@"YES" forState: UIControlStateNormal];
    else
        [gpsButton setTitle:@"NO" forState: UIControlStateNormal];
    //[gpsButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
     gpsButton.backgroundColor = [UIColor clearColor];
}
- (IBAction)gpsButtonTouchDown:(id)sender {
    gpsButton.backgroundColor = [UIColor redColor];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual:focalLengthField])
        textField.selectedTextRange = [textField
                                   textRangeFromPosition:textField.beginningOfDocument
                                   toPosition:textField.beginningOfDocument];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NewRollInfo"]) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap on a value to change it.\n\nTap on Start to begin.\n\nSwipe Down to go cancel the new roll.\n\n\n\n\n\n";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(([textField.text isEqualToString:@"F/"] || [[textField.text substringFromIndex:textField.text.length-2] isEqualToString:@"mm"]) && [string isEqualToString:@""] && textField.text.length == 2){
        return NO;
    }
    
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
