//
//  CustomDefaultsCell.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/20/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomDefaultsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *filmLabel;
@property (weak, nonatomic) IBOutlet UILabel *isoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (assign, nonatomic) NSInteger index;
@end
