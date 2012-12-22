//
//  SettingDefaultsViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/20/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "SettingDefaultsViewController.h"
#import "TTAlertView.h"
#import "DatabaseControl.h"

@interface SettingDefaultsViewController ()
@property (strong,nonatomic) DatabaseControl *dataController;
@end

@implementation SettingDefaultsViewController
#define kOFFSET_FOR_KEYBOARD 80.0
@synthesize filmTextField;
@synthesize isoTextField;
@synthesize exposureTextField;
@synthesize cameraTextField;
@synthesize focalTextField;
@synthesize apertureTextField;
@synthesize gpsButton;
@synthesize saveButton;
@synthesize update;
@synthesize defaultLabel;
@synthesize dataController=_dataController;
@synthesize rowID;
@synthesize data;

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

- (void)dismissKeyboard
{
    [filmTextField resignFirstResponder];
    [isoTextField resignFirstResponder];
    [exposureTextField resignFirstResponder];
    [cameraTextField resignFirstResponder];
    [focalTextField resignFirstResponder];
    [apertureTextField resignFirstResponder];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];
    
    
	UIFont *generalFont = [UIFont fontWithName:@"Walkway SemiBold" size:24];
    UIColor *fontColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    
    filmTextField.textColor = fontColor;
    filmTextField.textAlignment = NSTextAlignmentLeft;
    filmTextField.font = generalFont;
    filmTextField.placeholder = @"Kodak T-Max";
    filmTextField.clearsOnBeginEditing = YES;
    
    isoTextField.textColor = fontColor;
    isoTextField.textAlignment = NSTextAlignmentLeft;
    isoTextField.font = generalFont;
    isoTextField.placeholder = @"1600";
    isoTextField.clearsOnBeginEditing = YES;
    
    exposureTextField.textColor = fontColor;
    exposureTextField.textAlignment = NSTextAlignmentLeft;
    exposureTextField.font = generalFont;
    exposureTextField.placeholder = @"24";
    exposureTextField.clearsOnBeginEditing = YES;
    
    cameraTextField.textColor = fontColor;
    cameraTextField.textAlignment = NSTextAlignmentLeft;
    cameraTextField.font = generalFont;
    cameraTextField.placeholder = @"Canonet 28";
    cameraTextField.clearsOnBeginEditing = YES;
    
    focalTextField.textColor = fontColor;
    focalTextField.textAlignment = NSTextAlignmentLeft;
    focalTextField.font = generalFont;
    focalTextField.placeholder = @"40mm";
    focalTextField.clearsOnBeginEditing = YES;
    
    apertureTextField.textColor = fontColor;
    apertureTextField.textAlignment = NSTextAlignmentLeft;
    apertureTextField.font = generalFont;
    apertureTextField.placeholder = @"F/2.8";
    apertureTextField.clearsOnBeginEditing = YES;
    
    saveButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    saveButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:40];
    [saveButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    
    gpsButton.backgroundColor = [UIColor clearColor];
    gpsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    gpsButton.titleLabel.font = generalFont;
    [gpsButton setTitleColor:fontColor forState:UIControlStateNormal];
    
    if (update)
    {
        
        NSString *rowData = [NSString stringWithFormat:@"SELECT * FROM Defaults WHERE id = %@",rowID];
        data = [self.dataController readTable:rowData];
        defaultLabel.text = @"Update Defaults:";
        filmTextField.text = [[data objectAtIndex:0] objectAtIndex:2];
        isoTextField.text = [[data objectAtIndex:0] objectAtIndex:3];
        exposureTextField.text = [[data objectAtIndex:0] objectAtIndex:4];
        cameraTextField.text = [[data objectAtIndex:0] objectAtIndex:5];
        focalTextField.text = [[data objectAtIndex:0] objectAtIndex:6];
        apertureTextField.text = [[data objectAtIndex:0] objectAtIndex:7];
        if([[[data objectAtIndex:0] objectAtIndex:8] isEqualToString:@"YES"])
            [gpsButton setTitle:@"YES" forState: UIControlStateNormal];
        else
            [gpsButton setTitle:@"NO" forState: UIControlStateNormal];
        [saveButton setTitle:@"Update" forState: UIControlStateNormal];
    }
    else
    {
        defaultLabel.text = @"Add Defaults:";
        [gpsButton setTitle:@"NO" forState: UIControlStateNormal];
        [saveButton setTitle:@"Save" forState: UIControlStateNormal];
    }
    
}


- (void)saveData
{
    NSInteger toSelect;
    NSArray *checkForDefaults = [self.dataController readTable:@"SELECT * FROM Defaults WHERE isDefault = 1;"];
    if (checkForDefaults.count == 0)
        toSelect = 1;
    else{
        toSelect = 0;
        [self.dataController sendSqlData:[NSString stringWithFormat:@"UPDATE Defaults SET isDefault = '%d' WHERE id = '%@'",toSelect,[[checkForDefaults objectAtIndex:0] objectAtIndex:0]] whichTable:@"Defaults"];
        toSelect = 1;
    }
    
    NSString *focal = @"";
    NSString *aperture = @"";
    if (focalTextField.text.length > 2)
        focal = [focalTextField.text substringToIndex:focalTextField.text.length-2];
    if (apertureTextField.text.length > 2)
        aperture = [apertureTextField.text substringFromIndex:2];
    
    NSString *defaultsTable = [NSString stringWithFormat:@"INSERT INTO Defaults ('isDefault','FilmName','Iso','Exposure','Camera','Focal','Aperture','Gps') VALUES ('%d','%@','%@','%@','%@','%@','%@','%@');",toSelect,filmTextField.text,isoTextField.text,exposureTextField.text,cameraTextField.text,focal,aperture,gpsButton.currentTitle];
    [self.dataController sendSqlData:defaultsTable whichTable:@"Defaults"];
}

- (void)updateData
{
    
    NSString *focal = @"";
    NSString *aperture = @"";
    if (focalTextField.text.length > 2)
        focal = [focalTextField.text substringToIndex:focalTextField.text.length-2];
    if (apertureTextField.text.length > 2)
        aperture = [apertureTextField.text substringFromIndex:2];
    
    NSString *updateData = [NSString stringWithFormat:@"UPDATE Defaults SET Filmname = '%@', Iso = '%@', Exposure ='%@', Camera = '%@', Focal = '%@', Aperture = '%@', Gps = '%@' WHERE Id = '%@';",filmTextField.text,isoTextField.text,exposureTextField.text,cameraTextField.text,focal,aperture,gpsButton.currentTitle,rowID];
    [self.dataController sendSqlData:updateData whichTable:@"Defaults"];
}

- (IBAction)gpsButtonPressed:(UIButton *)sender {
    NSLog(@"testing gpsButton");
    if([sender.currentTitle isEqualToString:@"NO"])
    {
        [self animateButton:@"FromBottom"];
        [sender setTitle:@"YES" forState: UIControlStateNormal];
    }
    else
    {
        [self animateButton:@"FromTop"];
        [sender setTitle:@"NO" forState: UIControlStateNormal];
    }
}

- (IBAction)saveButtonPressed:(id)sender {
    if (![filmTextField.text isEqualToString:@""] || ![isoTextField.text isEqualToString:@""] || ![cameraTextField.text isEqualToString:@""])
    {
        if(update)
            [self updateData];
        else
            [self saveData];
    }else
    {
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Roll Not Saved"
                                                        message:@"Roll was not saved because all fields were empty"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:filmTextField] || [textField isEqual:cameraTextField])
        if((textField.text.length >= 12) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:12];
            [self performSelector:@selector(dismissKeyboard)];
        }
    if ([textField isEqual:isoTextField])
        if((textField.text.length >= 4) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:4];
            [self performSelector:@selector(dismissKeyboard)];
        }
    if ([textField isEqual:exposureTextField])
        if((textField.text.length >= 2) && ![string isEqualToString:@""]){
            textField.text = [textField.text substringToIndex:2];
            [self performSelector:@selector(dismissKeyboard)];
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
    if ([textField isEqual:focalTextField])
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

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if([textField isEqual:focalTextField])
    {
        [self setViewMovedUp:YES];
        textField.text = @"mm";
        textField.selectedTextRange = [textField
                                       textRangeFromPosition:textField.beginningOfDocument
                                       toPosition:textField.beginningOfDocument];
    }
    if([textField isEqual:apertureTextField])
    {
        [self setViewMovedUp:YES];
        textField.text = @"F/";
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if([textField isEqual:focalTextField] || [textField isEqual:apertureTextField])
        [self setViewMovedUp:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
