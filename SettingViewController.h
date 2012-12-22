//
//  SettingViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/20/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *defaultsTableView;
@property (weak, nonatomic) IBOutlet UIButton *addRollDefaultsButton;
@property (weak, nonatomic) IBOutlet UILabel *selectDefaultLabel;
@end
