//
//  CustomSegue.m
//  FilmNotes
//
//  Created by Robert Ozimek on 11/29/12.
//  Copyright (c) 2012 wtc. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue
- (void) perform {
    /*[[self sourceViewController] setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:YES];*/
     UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
     UIViewController *destinationController = (UIViewController*)[self destinationViewController];
     
     CATransition* transition = [CATransition animation];
     transition.duration = .30;
     transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
     transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
     
    [sourceViewController presentViewController:destinationController animated:NO completion:^{[[destinationController view].layer addAnimation:transition
                                                                                                                                         forKey:kCATransition];}];
}


@end
