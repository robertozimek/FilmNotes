//
//  LocationController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/4/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AddressAnnotation.h"
#import "TTAlertView.h"

@interface LocationController : NSObject <CLLocationManagerDelegate,MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    
}
@property (strong, nonatomic) CLLocationManager *location;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lon;
@property (strong, nonatomic) NSTimer *locationTimer;
-(NSString *)locationServicesStatus;
@end
