//
//  LocationController.m
//  FilmNotes
//
//  Created by Robert Ozimek on 12/4/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "LocationController.h"


@implementation LocationController
@synthesize lat, lon;
@synthesize location;
@synthesize locationTimer;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.location = [[CLLocationManager alloc] init];
        location.delegate=self;
        location.desiredAccuracy=kCLLocationAccuracyBest;
        location.distanceFilter=100;
    }
    return self;
}

-(NSString *)locationServicesStatus
{
    NSString *status = @"";
    if([CLLocationManager locationServicesEnabled])
    {
        switch([CLLocationManager authorizationStatus]){
            case kCLAuthorizationStatusAuthorized:
                status = @"authorized";
                break;
            case kCLAuthorizationStatusDenied:
                status = @"denied";
                break;
            case kCLAuthorizationStatusRestricted:
                status = @"restricted";
                break;
            case kCLAuthorizationStatusNotDetermined:
                status = @"unknown";
        }
    }
    else{
        // locationServicesEnabled was set to NO
        status = @"disabled";
    }
    return status;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @try
    {
        if(newLocation.horizontalAccuracy > 100)
        {
            NSLog(@"Ignoring GPS location more than 100 meters inaccurate :%f", newLocation.horizontalAccuracy);
            return;
        }
        
        /*NSDate* eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        if (abs(howRecent) > 5.0)
        {
            NSLog(@"Ignoring GPS location more than 15 seconds old(cached) :%d", abs(howRecent));
            return;
        }*/
        lat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        lon = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        
        [location stopUpdatingLocation];
    }
    @catch (NSException* ex)
    {
        NSLog(@"Uncaught Error in didUpdateToLocation()");
    }
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *msg = @"Error obtaining location";

    TTAlertView *alert = [[TTAlertView alloc]
                          initWithTitle:@"Error"
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

@end
