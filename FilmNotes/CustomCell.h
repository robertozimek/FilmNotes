//
//  CustomCell.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/28/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell 
@property (weak,nonatomic) IBOutlet UILabel *film;
@property (weak,nonatomic) IBOutlet UILabel *camera;
@property (weak,nonatomic) IBOutlet UILabel *date;
@property (weak,nonatomic) IBOutlet UILabel *roll;

@end
