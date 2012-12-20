//
//  DecimalPointButton.h
//  iDeal
//
//  Created by David Casserly on 13/03/2010.
//  Copyright 2010 devedup.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	The UIButton that will have the decimal point on it
 */
@interface BackSlashButton : UIButton {
	
}

+ (BackSlashButton *) backSlashButton;

@end


/**
 *	The class used to create the keypad
 */
@interface NumberKeypadBackSlash : NSObject {
	
	UITextField *currentTextField;
	
	BackSlashButton *backSlashButton;
	
	NSTimer *showBackSlashTimer;
}

@property (nonatomic, retain) NSTimer *showBackSlashTimer;
@property (nonatomic, retain) BackSlashButton *backSlashButton;

@property (assign) UITextField *currentTextField;

#pragma mark -
#pragma mark Show the keypad

+ (NumberKeypadBackSlash *) keypadForTextField:(UITextField *)textField; 

- (void) removeButtonFromKeyboard;

@end


