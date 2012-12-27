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

-(DatabaseControl *)dataController
{
    if (!_dataController) _dataController = [[DatabaseControl alloc] init];
    return _dataController;
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    /*UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                          bundle:nil];
    NewRollViewController* newRollView = [storyBoard instantiateViewControllerWithIdentifier:@"NewRoll"];
    [self presentViewController:newRollView animated:YES completion:nil];*/
    [self performSegueWithIdentifier:@"NewRollView" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.data = [self.dataController readTable:@"SELECT * FROM Roll"];
    [self.aTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rollButton.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    [self.rollButton setTitle: @"New Roll" forState: UIControlStateNormal];
    self.rollButton.titleLabel.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    [self.rollButton setTitleColor:[UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
    self.rollButton.titleLabel.font = [UIFont fontWithName:@"Walkway SemiBold" size:48];
    
    [self.dataController createTable];
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizer];
}


- (void)viewDidAppear:(BOOL)animated
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunched"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunched"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(firstRunOpenPreset) withObject:nil afterDelay:0.25];
    }
}

- (void)firstRunOpenPreset
{
    [self performSegueWithIdentifier:@"SettingsSeque" sender:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *rollKey = [NSString stringWithFormat:@"RollNumber %@",[[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0]];
        [self.dataController removeRow:[[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0] inTable:@"Roll"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:rollKey])
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:rollKey];
        self.data = [self.dataController readTable:@"SELECT * FROM Roll"];
        [tableView reloadData];
        //[self.data objectAtIndex:[data count]-indexPath.row-1] objectAtIndex:0];
    }
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"customCell";
    
    CustomCell *cell = [tableView
                        dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSLog(@"Cell Created");
        /*
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCellView" owner:self options:nil];
        cell = [nibObjects objectAtIndex:0];
         */
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.roll.font = [UIFont fontWithName:@"Walkway SemiBold" size:34];
    cell.film.font = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    cell.camera.font = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    cell.date.font = [UIFont fontWithName:@"Walkway SemiBold" size:20];
    
    UIColor *cellTextColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    cell.film.textColor = cellTextColor;
    cell.camera.textColor = cellTextColor;
    cell.date.textColor = cellTextColor;

    cell.roll.text = [NSString stringWithFormat:@"%d",[self.data count]-indexPath.row];
    cell.film.text = [[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:2];
    cell.camera.text = [[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:4];
    cell.date.text = [[data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:5];

    cell.roll.textAlignment = NSTextAlignmentCenter;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"RollView" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewInfo"]) {
        MoreInfoViewController *moreViewController = segue.destinationViewController;
        moreViewController.InfoText = @"Tap New Roll or Swipe up to start a new roll.\n\nTap on a roll to open it.\n\nTap on the gear icon to open roll presets.";
    }
    if ([segue.identifier isEqualToString:@"RollView"]) {
        NSIndexPath *indexPath = [self.aTableView indexPathForSelectedRow];
        RollViewController *rollViewController = segue.destinationViewController;
        rollViewController.RollNumber = [[self.data objectAtIndex:[self.data count]-indexPath.row-1] objectAtIndex:0];
    }
    if ([segue.identifier isEqualToString:@"NewRollView"]) {
        RollDataViewController *rollDataViewController = segue.destinationViewController;
        rollDataViewController.commitTag = 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

@end
