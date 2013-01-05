//
//  ViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/28/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseControl.h"
#import "CustomCell.h"
#import "MoreInfoViewController.h"
#import "RollViewController.h"
#import "RollDataViewController.h"

@interface ViewController ()
@property (strong, nonatomic) DatabaseControl *dataController;
@end

@implementation ViewController
@synthesize rollButton;
@synthesize aTableView;
@synthesize settingGearButton;
@synthesize data;
@synthesize dataController=_dataController;

#pragma mark - Lazy Instantiation of DatabaseControl Class

-(DatabaseControl *)dataController
{
    // if _dataController is nil instantiate it
    if (!_dataController) _dataController = [[DatabaseControl alloc] init];
    return _dataController;
}

#pragma mark - Handle Swipe Gesture Method

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    /*UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                          bundle:nil];
    NewRollViewController* newRollView = [storyBoard instantiateViewControllerWithIdentifier:@"NewRoll"];
    [self presentViewController:newRollView animated:YES completion:nil];*/
    
    //Segue to the View Controller with NewRollView identifier
    [self performSegueWithIdentifier:@"NewRollView" sender:nil];
}

#pragma mark - View methods

- (void)viewWillAppear:(BOOL)animated
{
    //Retrieve all the rows of the Roll table in the database 
    self.data = [self.dataController readTable:@"SELECT * FROM Roll"];
    
    //Reload the tableview with Roll data
    [self.aTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set the New Roll button title, colors, and font
    self.rollButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    [self.rollButton setTitle: @"New Roll" forState: UIControlStateNormal];
    self.rollButton.titleLabel.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    [self.rollButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    self.rollButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:48];
    
    //Create Table in the database if they do not exist
    [self.dataController createTable];
    
    //Instantance of the swipe gesture from the Up direction
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizer];
}


- (void)viewDidAppear:(BOOL)animated
{
    //Determine if this is the first time the app has been launched
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunched"])
    {
        //Set NSUserDefaults for hasLaunched to YES
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Seque to Preset View Controller after a delay
        [self performSelector:@selector(firstRunOpenPreset) withObject:nil afterDelay:0.25];
    }
}

#pragma mark - Rotation Methods

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - Segue to Preset View Controller

- (void)firstRunOpenPreset
{
    [self performSegueWithIdentifier:@"SettingsSeque" sender:nil];
}

#pragma mark - Table View DataSource and Delegate

//Swipe to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //If delete was pressed delete the row in the Roll Table and reload Table View
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *rollKey = [NSString stringWithFormat:@"RollNumber %@",[[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0]];
        [self.dataController removeRow:[[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0] inTable:@"Roll"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:rollKey])
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:rollKey];
        self.data = [self.dataController readTable:@"SELECT * FROM Roll"];
        [tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    //Set the number of table cell rows to the size of the data array
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //String with the name of the Cell Identifier
    static NSString *CellIdentifier = @"customCell";
    
    //Set reusable cell to the custom cell with the idenifier
    CustomCell *cell = [tableView
                        dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSLog(@"Cell Created");
        /*
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCellView" owner:self options:nil];
        cell = [nibObjects objectAtIndex:0];
         */
        
        //If cell does not exist alloc and instantiate the Custom Cell
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    //Set the fonts of labels in the Custom Cell
    cell.roll.font = [UIFont fontWithName:@"Walkway SemiBold" size:34];
    cell.film.font = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    cell.camera.font = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    cell.date.font = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    
    //Set the colors of labels in the Custom Cell
    UIColor *cellTextColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    cell.film.textColor = cellTextColor;
    cell.camera.textColor = cellTextColor;
    cell.date.textColor = cellTextColor;

    //Set the labels of the rows in reverse so that the newest row is in the first cell
    cell.roll.text = [NSString stringWithFormat:@"%d",[self.data count]-indexPath.row];
    cell.film.text = [[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:2];
    cell.camera.text = [[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:4];
    cell.date.text = [[data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:5];

    cell.roll.textAlignment = NSTextAlignmentCenter;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //When the user selects a cell, Segue to the Roll View Controller
    [self performSegueWithIdentifier:@"RollView" sender:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set height of the cell
    return 105;
}

#pragma mark - Preparing for Segue 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Pass data to View Controllers before seguing to it
    if ([segue.identifier isEqualToString:@"ViewInfo"]) {
        //Instantiate More Info View Controller
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        //Set InfoText string in More View Controller
        moreViewController.InfoText = @"Tap New Roll or Swipe up to start a new roll.\n\nTap on a roll to open it.\n\nTap on the gear icon to open roll presets.";
    }
    if ([segue.identifier isEqualToString:@"RollView"]) {
        //Retrieve indexPath of the selected row
        NSIndexPath *indexPath = [self.aTableView indexPathForSelectedRow];
        //Instantiate Roll View Controller
        RollViewController *rollViewController = segue.destinationViewController;
        //Set RollNumber NSInteger to the roll id of selected row
        rollViewController.RollNumber = [[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0];
    }
    if ([segue.identifier isEqualToString:@"NewRollView"]) {
        //Instantiate Roll Data View Controller
        RollDataViewController *rollDataViewController = segue.destinationViewController;
        //Set commitTag NSInteger to 1
        rollDataViewController.commitTag = 1;
    }
}

#pragma mark - Memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
