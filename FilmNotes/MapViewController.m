//
//  MapViewController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/5/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "MapViewController.h"
#import "AddressAnnotation.h"
#import <AddressBook/AddressBook.h>

@interface MapViewController ()
@property (strong, nonatomic) CLLocation *location;
@end

@implementation MapViewController
@synthesize location;
@synthesize lat;
@synthesize lon;
@synthesize exposure;
@synthesize mapView;
@synthesize standardButton;
@synthesize satelliteButton;
@synthesize hybridButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Font
    UIFont *mapTypeButtonFont = [UIFont fontWithName:@"Walkway SemiBold" size:18];
    
    //Colors
    UIColor *buttonOneColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    UIColor *buttonTwoColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    
    //Set Button Fonts
    self.standardButton.titleLabel.font = mapTypeButtonFont;
    self.satelliteButton.titleLabel.font = mapTypeButtonFont;
    self.hybridButton.titleLabel.font = mapTypeButtonFont;
    
    //Set Button Background Colors
    self.standardButton.backgroundColor = buttonOneColor;
    self.hybridButton.backgroundColor = buttonTwoColor;
    self.satelliteButton.backgroundColor = buttonTwoColor;
    
    //Set Button Title Colors
    [self.standardButton setTitleColor:buttonTwoColor forState:UIControlStateNormal];
    [self.satelliteButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
    [self.hybridButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
    
    //Set Button Titles
    [self.standardButton setTitle:@"Standard" forState:UIControlStateNormal];
    [self.satelliteButton setTitle:@"Satellite" forState:UIControlStateNormal];
    [self.hybridButton setTitle:@"Hybrid" forState:UIControlStateNormal];

    //Set Button Tags
    self.standardButton.tag = 1;
    self.satelliteButton.tag = 2;
    self.hybridButton.tag = 3;
    
    //Set Default MapType
    self.mapView.mapType = MKMapTypeStandard;
    
    //Create a type CLLLocation that holds the latitude and longitude
    self.location = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
}

- (IBAction)mapTypeButtonPressed:(UIButton *)sender {
    //Colors
    UIColor *buttonOneColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    UIColor *buttonTwoColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    
    //If button with tag one set MapType to Standard and set button colors
    if(sender.tag == 1)
    {
        self.mapView.mapType = MKMapTypeStandard;
        self.standardButton.backgroundColor = buttonOneColor;
        [self.standardButton setTitleColor:buttonTwoColor forState:UIControlStateNormal];
        self.satelliteButton.backgroundColor = buttonTwoColor;
        [self.satelliteButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
        self.hybridButton.backgroundColor = buttonTwoColor;
        [self.hybridButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
    }
    
    //If button with tag two set MapType to Satellite and set button colors
    if(sender.tag == 2)
    {
        self.mapView.mapType = MKMapTypeSatellite;
        self.standardButton.backgroundColor = buttonTwoColor;
        [self.standardButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
        self.satelliteButton.backgroundColor = buttonOneColor;
        [self.satelliteButton setTitleColor:buttonTwoColor forState:UIControlStateNormal];
        self.hybridButton.backgroundColor = buttonTwoColor;
        [self.hybridButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
    }
    
    //If button with tag three set MapType to Hybrid and set button colors
    if(sender.tag == 3)
    {
        self.mapView.mapType = MKMapTypeHybrid;
        self.standardButton.backgroundColor = buttonTwoColor;
        [self.standardButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
        self.satelliteButton.backgroundColor = buttonTwoColor;
        [self.satelliteButton setTitleColor:buttonOneColor forState:UIControlStateNormal];
        self.hybridButton.backgroundColor = buttonOneColor;
        [self.hybridButton setTitleColor:buttonTwoColor forState:UIControlStateNormal];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    //Create Pin and Annotation
    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:self.location.coordinate];
    //Set Annotation Title
    addAnnotation.title = [NSString stringWithFormat:@"Exposure %@",self.exposure];
    //Add Anotation to MapView
    [self.mapView addAnnotation:addAnnotation];
    
    //Set Zoom in Region
    MKCoordinateSpan span;
    span.latitudeDelta = .009;
    span.longitudeDelta = .009;
    MKCoordinateRegion region;
    region.center = self.location.coordinate;
    region.span = span;
    
    //Set Zoom In Region and Animate It
	[self.mapView setRegion:region animated:YES];
    
    //Animate and Add Annotation
    [self.mapView selectAnnotation:addAnnotation animated:YES];
    
}

- (IBAction)backButtonPressed:(id)sender {
    //Return to Roll View
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openMapsButtonPressed:(id)sender {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //Convert Coordinates Into Address
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       
                       if (placemarks && placemarks.count > 0)
                       {
                           CLPlacemark *placemark = placemarks[0];
                           
                           NSDictionary *addressDictionary =
                           placemark.addressDictionary;
                           
                           NSString *address = [addressDictionary
                                                objectForKey:(NSString *)kABPersonAddressStreetKey];
                           NSString *city = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressCityKey];
                           NSString *state = [addressDictionary
                                              objectForKey:(NSString *)kABPersonAddressStateKey];
                           NSString *zip = [addressDictionary 
                                            objectForKey:(NSString *)kABPersonAddressZIPKey];
                           
                           NSDictionary *addresses = @{
                                                     (NSString *)kABPersonAddressStreetKey: address,
                                                     (NSString *)kABPersonAddressCityKey: city,
                                                     (NSString *)kABPersonAddressStateKey: state,
                                                     (NSString *)kABPersonAddressZIPKey: zip,
                                                     (NSString *)kABPersonAddressCountryCodeKey: @"US"
                                                     };
                           CLLocationCoordinate2D coords =
                           CLLocationCoordinate2DMake(self.location.coordinate.latitude,self.location.coordinate.longitude);
                           
                           //Store Coordinates with Address
                           MKPlacemark *place = [[MKPlacemark alloc]
                                                 initWithCoordinate:coords addressDictionary:addresses];
                           //Send the Coordinates and Address to Apple Maps
                           MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
                           
                           //Give the address a Title Annotation
                           [mapItem setName:[NSString stringWithFormat:@"Exposure %@",self.exposure]];
                           
                           //Open In Maps
                           [mapItem openInMapsWithLaunchOptions:nil];
                       }
                       
                   }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
