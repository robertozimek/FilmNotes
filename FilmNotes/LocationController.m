#import "LocationController.h"

@implementation LocationController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    [self.delegate locationUpdate:newLocation];
}

-(NSString *)locationServicesStatus
{
    NSString *status = @"";
    if([CLLocationManager locationServicesEnabled])
    {
        switch([CLLocationManager authorizationStatus]){
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                status = @"authorized";
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
                status = @"authorized";
                break;
            case kCLAuthorizationStatusRestricted:
                status = @"restricted";
                break;
            case kCLAuthorizationStatusDenied:
                status = @"denied";
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


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	[self.delegate locationError:error];
}
@end
