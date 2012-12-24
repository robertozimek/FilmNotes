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
@property (weak, nonatomic) NSString *exposure;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *standardButton;
@property (weak, nonatomic) IBOutlet UIButton *satelliteButton;
@property (weak, nonatomic) IBOutlet UIButton *hybridButton;
@end