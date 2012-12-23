//
//  AddressAnnotation.m
//  learnCoreLocations
//
//  Created by Robert Ozimek on 12/4/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation
@synthesize coordinate;
@synthesize title;

- (NSString *)subtitle{
	return nil;
}


-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end