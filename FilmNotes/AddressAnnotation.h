//
//  AddressAnnotation.h
//  learnCoreLocations
//
//  Created by Robert Ozimek on 12/4/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface AddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}
@property (nonatomic, copy) NSString *title;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
@end