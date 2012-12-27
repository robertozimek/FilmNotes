//
//  MoveViewTextField.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/25/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoveViewTextField;
@protocol MoveViewTextFieldDelegate <UITextFieldDelegate>
@optional
@required
-(void)setViewMovedUp:(BOOL)movedUp;
-(void)moveViewTextField:(UITextField *)textField;
-(void)dismissMoveViewTextField:(UITextField *)textField;
@end

@interface MoveViewTextField : UITextField
{
    __weak id <MoveViewTextFieldDelegate> delegate;
}
@property (nonatomic, weak) id  <MoveViewTextFieldDelegate> delegate;

@end
