//
//  SettingViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/20/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "SettingViewController.h"
#import "DatabaseControl.h"
#import "CustomDefaultsCell.h"
#import "SettingDefaultsViewController.h"

@interface SettingViewController ()
@property (strong,nonatomic) DatabaseControl *dataController;
@property (strong,nonatomic) NSArray *data;
@property (strong,nonatomic) NSString *lastSelected;
@property (strong,nonatomic) NSIndexPath *selectedPath;
@property (assign) NSInteger buttonTag;
@end

@implementation SettingViewController
@synthesize defaultsTableView;
@synthesize addRollDefaultsButton;
@synthesize selectDefaultLabel;
@synthesize dataController=_dataController;
@synthesize data;
@synthesize lastSelected;
@synthesize selectedPath;
@synthesize buttonTag;


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

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizer];
    
    self.defaultsTableView.dataSource = self;
    self.defaultsTableView.delegate = self;
    
    addRollDefaultsButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    addRollDefaultsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addRollDefaultsButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:26];
    [addRollDefaultsButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    [addRollDefaultsButton setTitle:@"Add Roll Defaults" forState: UIControlStateNormal];
    
}
- (IBAction)editButtonPressed:(UIButton *)sender {
    buttonTag = sender.tag;
}


-(void)viewWillAppear:(BOOL)animated
{
    data = [self.dataController readTable:@"SELECT * FROM Defaults"];
    if ([data count] == 0)
        selectDefaultLabel.hidden = YES;
    else
        selectDefaultLabel.hidden = NO;
    [defaultsTableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataController removeRow:[[data objectAtIndex:[data count]-indexPath.row-1] objectAtIndex:0] inTable:@"Defaults"];
        data = [self.dataController readTable:@"SELECT * FROM Defaults"];
        [tableView reloadData];
        if ([data count] == 0)
            selectDefaultLabel.hidden = YES;
        else
            selectDefaultLabel.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CustomDefaultsCell";
    
    CustomDefaultsCell *cell = [tableView
                        dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSLog(@"Settings Cell Created");
        
        cell= [[CustomDefaultsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSInteger reserveIndex = [data count]-indexPath.row-1;
    
    UIFont *cellFont = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    cell.filmLabel.font = cellFont;
    cell.isoLabel.font = cellFont;
    cell.cameraLabel.font = cellFont;
    
    UIColor *cellTextColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    cell.filmLabel.textColor = cellTextColor;
    cell.isoLabel.textColor = cellTextColor;
    cell.cameraLabel.textColor = cellTextColor;
    
    cell.filmLabel.textAlignment = NSTextAlignmentLeft;
    cell.isoLabel.textAlignment = NSTextAlignmentLeft;
    cell.cameraLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.filmLabel.text = [[data objectAtIndex:reserveIndex] objectAtIndex:2];
    cell.isoLabel.text = [[data objectAtIndex:reserveIndex] objectAtIndex:3];
    cell.cameraLabel.text = [[data objectAtIndex:reserveIndex] objectAtIndex:4];
    cell.editButton.tag = [[[data objectAtIndex:reserveIndex] objectAtIndex:0] integerValue];
    
    if([[[data objectAtIndex:reserveIndex] objectAtIndex:1]  isEqualToString:@"1"])
    {
        selectedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        lastSelected = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [tableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != (long)[lastSelected integerValue])
        [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[lastSelected integerValue] inSection:0] animated:YES];
    if (![lastSelected isEqualToString:@""])
    {
        NSString *removeDefault = [NSString stringWithFormat:@"UPDATE Defaults SET isDefault = '%d' WHERE id = '%@';",0,[[data objectAtIndex:[data count]-[lastSelected integerValue]-1] objectAtIndex:0]];
        [self.dataController sendSqlData:removeDefault whichTable:@"Defaults"];
    }
    
    NSString *addDefault = [NSString stringWithFormat:@"UPDATE Defaults SET isDefault = '%d' WHERE id = '%@';",1,[[data objectAtIndex:[data count]-indexPath.row-1] objectAtIndex:0]];
    
    [self.dataController sendSqlData:addDefault whichTable:@"Defaults"];
    
    lastSelected = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == (long)[lastSelected integerValue])
    {
        NSString *removeDefault = [NSString stringWithFormat:@"UPDATE Defaults SET isDefault = '%d' WHERE id = '%@';",0,[[data objectAtIndex:[data count]-indexPath.row-1] objectAtIndex:0]];
        [self.dataController sendSqlData:removeDefault whichTable:@"Defaults"];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddDefaultsSegue"]) {
        SettingDefaultsViewController *settingDefaultsViewController = segue.destinationViewController;
        settingDefaultsViewController.update = NO;
    }
    if ([segue.identifier isEqualToString:@"UpdateDefaultsSegue"]) {
        SettingDefaultsViewController *settingDefaultsViewController = segue.destinationViewController;
        settingDefaultsViewController.update = YES;
        settingDefaultsViewController.rowID = [NSString stringWithFormat:@"%ld",(long)buttonTag];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
