//
//  MoreInfoViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *InfoTextView;
@property (weak, nonatomic) NSString *InfoText;
@end
