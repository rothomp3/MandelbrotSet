//
//  RTViewController.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTViewController.h"
#import "RTMandelbrotView.h"

@implementation RTViewController
- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    RTMandelbrotView* v = [[RTMandelbrotView alloc] initWithFrame:frame];
    
    [self setView:v];
}
@end
