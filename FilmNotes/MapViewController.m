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
	
}

- (void)viewDidAppear:(BOOL)animated
{
    location = [[CLLocation alloc] initWithLatitude:[lat floatValue] longitude:[lon floatValue]];
    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location.coordinate];
    addAnnotation.title = [NSString stringWithFormat:@"Exposure %@",exposure];
    MKCoordinateSpan span;
    span.latitudeDelta = .009;
    span.longitudeDelta = .009;
    MKCoordinateRegion region;
    region.center = location.coordinate;
    region.span = span;
    [mapView setRegion:region animated: TRUE];
    [mapView addAnnotation:addAnnotation];
}
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)openMapsButtonPressed:(id)sender {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
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
                           
                           NSLog(@"%@ %@ %@ %@", address,city, state, zip);
                           CLLocationCoordinate2D coords =
                           CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
                           
                           
                           MKPlacemark *place = [[MKPlacemark alloc]
                                                 initWithCoordinate:coords addressDictionary:addresses];
                           MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
                           [mapItem setName:[NSString stringWithFormat:@"Exposure %@",exposure]];
                           
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
