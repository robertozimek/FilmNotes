//
//  MapViewController.h
//  FilmNotes
//
//  Created by Robert Ozimek on 12/5/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "LocationController.h"

@interface MapViewController : UIViewController
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lon;
@property (strong, nonatomic) NSString *exposure;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end