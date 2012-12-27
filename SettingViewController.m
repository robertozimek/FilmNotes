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
#import "MoreInfoViewController.h"

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
    
    self.addRollDefaultsButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    self.addRollDefaultsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.addRollDefaultsButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:38];
    [self.addRollDefaultsButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    [self.addRollDefaultsButton setTitle:@"Add Presets" forState: UIControlStateNormal];
}
- (IBAction)editButtonPressed:(UIButton *)sender {
    self.buttonTag = sender.tag;
}


-(void)viewWillAppear:(BOOL)animated
{
    self.data = [self.dataController readTable:@"SELECT * FROM Defaults"];
    if ([self.data count] == 0)
        self.selectDefaultLabel.hidden = YES;
    else
        self.selectDefaultLabel.hidden = NO;
    [self.defaultsTableView reloadData];
    
    self.isDefault = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"selectedDefault"];
    
    if (![self.isDefault isEqualToString:@"No Default"] && (self.isDefault != nil))
    {
        [self.defaultsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[self.isDefault integerValue] inSection:0] animated:NO scrollPosition:UITableViewRowAnimationTop];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self selectIndex];
}

-(void)selectIndex
{
    if (![self.isDefault isEqualToString:@"No Default"] && (self.isDefault != nil))
    {
        NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[self.isDefault integerValue] inSection:0];
        [self.defaultsTableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (![self.isDefault isEqualToString:@"No Default"] && (self.isDefault != nil))
        [[NSUserDefaults standardUserDefaults] setObject:[[self.data objectAtIndex:([self.data count]-[self.isDefault integerValue]-1)] objectAtIndex:0] forKey:@"theDefault"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"theDefault"];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataController removeRow:[[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0] inTable:@"Defaults"];
        self.data = [self.dataController readTable:@"SELECT * FROM Defaults"];
        [tableView reloadData];
        if (indexPath.row == [self.isDefault integerValue])
        {
            isDefault = @"No Default";
            [[NSUserDefaults standardUserDefaults] setObject:self.isDefault forKey:@"selectedDefault"];
        }
        else{
            if (self.data.count != 0  && ![self.isDefault isEqualToString:@"No Default"] && [self.isDefault integerValue] > indexPath.row)
            {
                self.isDefault = [NSString stringWithFormat:@"%d",[self.isDefault integerValue]-1];
                NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[self.isDefault integerValue] inSection:0];
                [self.defaultsTableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else if (self.data.count != 0 && ![self.isDefault isEqualToString:@"No Default"] && [self.isDefault integerValue]  < indexPath.row)
            {
                NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[self.isDefault integerValue] inSection:0];
                [self.defaultsTableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else
            {
                self.isDefault = @"No Default";
            }
            [[NSUserDefaults standardUserDefaults] setObject:self.isDefault forKey:@"selectedDefault"];
        }
        
        if ([self.data count] == 0)
            self.selectDefaultLabel.hidden = YES;
        else
            self.selectDefaultLabel.hidden = NO;
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.isDefault isEqualToString:@"No Default"] && (self.isDefault != nil))
    {
        NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[self.isDefault integerValue] inSection:0];
        [self.defaultsTableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.isDefault isEqualToString:@"No Default"] && (self.isDefault != nil) && (![self.isDefault isEqualToString:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]))
    {
        NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:[self.isDefault integerValue] inSection:0];
        [self.defaultsTableView selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return UITableViewCellEditingStyleDelete;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
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
    NSInteger reserveIndex = [self.data count]-indexPath.row-1;
    
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
    
    cell.filmLabel.text = [[self.data objectAtIndex:reserveIndex] objectAtIndex:1];
    cell.isoLabel.text = [[self.data objectAtIndex:reserveIndex] objectAtIndex:2];
    cell.cameraLabel.text = [[self.data objectAtIndex:reserveIndex] objectAtIndex:4];
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
    self.isDefault = [NSString stringWithFormat:@"%d",indexPath.row];
    [[NSUserDefaults standardUserDefaults]
     setObject:self.isDefault forKey:@"selectedDefault"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isDefault = @"No Default";
    [[NSUserDefaults standardUserDefaults] setObject:self.isDefault forKey:@"selectedDefault"];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddDefaults"]) {
        RollDataViewController *rollDataViewController = segue.destinationViewController;
        rollDataViewController.commitTag = 2;
    }
    if ([segue.identifier isEqualToString:@"UpdateDefaults"]) {
        RollDataViewController *rollDataViewController  = segue.destinationViewController;
        rollDataViewController.commitTag = 3;
        rollDataViewController.rowID = buttonTag;
    }
    if ([segue.identifier isEqualToString:@"DefaultsInfo"]) {
        MoreInfoViewController *moreInfoViewController  = segue.destinationViewController;
        moreInfoViewController.InfoText = @"Tap Add Roll Presets to create new preset.\n\nTap on a roll to select it.\n\nTap on arrow to edit the roll presets.\n\nSwipe down to exit.";;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
