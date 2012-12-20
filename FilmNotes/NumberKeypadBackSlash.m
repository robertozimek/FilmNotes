//
//  DecimalPointButton.m
//  iDeal
//
//  Created by David Casserly on 13/03/2010.
//  Copyright 2010 devedup.com. All rights reserved.
//

#import "NumberKeypadBackSlash.h"

static UIImage *backgroundImageDepressed;

/**
 *
 */
@implementation BackSlashButton

+ (void) initialize {
	backgroundImageDepressed = [[UIImage imageNamed:@"backSlashKeyDownBackground.png"] retain];
}

- (id) init {
	if(self = [super initWithFrame:CGRectMake(0, 480, 105, 53)]) { //Initially hidden	
		//[super adjustsImageWhenDisabled:NO];
		self.titleLabel.font = [UIFont systemFontOfSize:35];
		[self setTitleColor:[UIColor colorWithRed:77.0f/255.0f green:84.0f/255.0f blue:98.0f/255.0f alpha:1.0] forState:UIControlStateNormal];	
		[self setBackgroundImage:backgroundImageDepressed forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[self setTitle:@"/" forState:UIControlStateNormal];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	//Bring in the button at same speed as keyboard
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2]; //we lose 0.1 seconds when we display it with timer
	self.frame = CGRectMake(0, 427, 105, 53);
	[UIView commitAnimations];
}

+ (BackSlashButton *) backSlashButton {
	BackSlashButton *button = [[BackSlashButton alloc] init];
	return [button autorelease];
}

@end

/**
 *
 */
@implementation NumberKeypadBackSlash

static NumberKeypadBackSlash *keypad;

//Retain
@synthesize backSlashButton;
@synthesize showBackSlashTimer;

//Assign
@synthesize currentTextField;

#pragma mark -
#pragma mark Release

- (void) dealloc {
	[backSlashButton release];
	[showBackSlashTimer release];
	[super dealloc];
}

//Private Method
- (void) addButtonToKeyboard:(BackSlashButton *)button {	
	//Add a button to the top, above all windows
	NSArray *allWindows = [[UIApplication sharedApplication] windows];
	int topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
	[keyboardWindow addSubview:button];	
}

//Private Method //This is executed after a delay from showKeypadForTextField
- (void) addTheBackSlashToKeyboard {	
	[keypad addButtonToKeyboard:keypad.backSlashButton];
}

//Private Method
- (void) backSlashPressed {
    NSString *currentText = currentTextField.text;
	if ([currentText rangeOfString:@"/" options:NSBackwardsSearch].length == 0)
        currentTextField.text = [currentTextField.text stringByAppendingString:@"/"];
}

/*
 Show the keyboard
 */
+ (NumberKeypadBackSlash *) keypadForTextField:(UITextField *)textField {
	if (!keypad) {
		keypad = [[NumberKeypadBackSlash alloc] init];
		keypad.backSlashButton = [BackSlashButton backSlashButton];
		[keypad.backSlashButton addTarget:keypad action:@selector(backSlashPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	keypad.currentTextField = textField;
	keypad.showBackSlashTimer = [NSTimer timerWithTimeInterval:0.1 target:keypad selector:@selector(addTheBackSlashToKeyboard) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:keypad.showBackSlashTimer forMode:NSDefaultRunLoopMode];
	return keypad;
}

/*
 Hide the keyboard
 */
- (void) removeButtonFromKeyboard {
	[self.showBackSlashTimer invalidate]; //stop any timers still wanting to show the button
	[self.backSlashButton removeFromSuperview];
}


@end

