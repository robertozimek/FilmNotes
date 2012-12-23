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
#import "RollDataViewController.h"

@interface SettingViewController ()
@property (strong,nonatomic) DatabaseControl *dataController;
@property (strong,nonatomic) NSArray *data;
@property (assign,nonatomic) NSInteger buttonTag;
@property (strong,nonatomic) NSString *isDefault;
@end

@implementation SettingViewController
@synthesize defaultsTableView;
@synthesize addRollDefaultsButton;
@synthesize selectDefaultLabel;
@synthesize dataController=_dataController;
@synthesize data;
@synthesize buttonTag;
@synthesize isDefault;

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
    
    isDefault = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"selectedDefault"];
 
    if (![isDefault isEqualToString:@"No Default"] && (isDefault != nil))
    {
        NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[isDefault integerValue] inSection:0];
        [defaultsTableView selectRowAtIndexPath:selectedPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (![isDefault isEqualToString:@"No Default"] && (isDefault != nil))
        [[NSUserDefaults standardUserDefaults] setObject:[[data objectAtIndex:([data count]-[isDefault integerValue]-1)] objectAtIndex:0] forKey:@"theDefault"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"theDefault"];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataController removeRow:[[data objectAtIndex:[data count]-indexPath.row-1] objectAtIndex:0] inTable:@"Defaults"];
        data = [self.dataController readTable:@"SELECT * FROM Defaults"];
        NSLog(@"deleted row");
        if (indexPath.row == [isDefault integerValue])
        {
            NSLog(@"default unset");
            isDefault = @"No Default";
            [[NSUserDefaults standardUserDefaults] setObject:isDefault forKey:@"selectedDefault"];
        }
        
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
    
    cell.filmLabel.text = [[data objectAtIndex:reserveIndex] objectAtIndex:1];
    cell.isoLabel.text = [[data objectAtIndex:reserveIndex] objectAtIndex:2];
    cell.cameraLabel.text = [[data objectAtIndex:reserveIndex] objectAtIndex:4];
    cell.editButton.tag = indexPath.row;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath != tableView.indexPathForSelectedRow)
        [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isDefault = [NSString stringWithFormat:@"%d",indexPath.row];
    [[NSUserDefaults standardUserDefaults]
     setObject:isDefault forKey:@"selectedDefault"];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isDefault = @"No Default";
    [[NSUserDefaults standardUserDefaults] setObject:isDefault forKey:@"selectedDefault"];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddDefaults"]) {
        RollDataViewController *rollDataViewController = segue.destinationViewController;
        rollDataViewController.fromView = @"AddDefaults";
    }
    if ([segue.identifier isEqualToString:@"UpdateDefaults"]) {
        RollDataViewController *rollDataViewController  = segue.destinationViewController;
        rollDataViewController.fromView = @"UpdateDefaults";
        rollDataViewController.rowID = buttonTag;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
