//
//  ViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 11/28/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>



@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *aTableView;
@property (weak, nonatomic) NSArray *data;
@end
