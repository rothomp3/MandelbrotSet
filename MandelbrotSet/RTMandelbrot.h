//
//  RTMandelbrot.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "complex.H"

@interface RTMandelbrot : NSObject

@property (nonatomic) Complex point;
@property (nonatomic) int maxIterations;
@property (nonatomic) int escapedAt;
@property (nonatomic) int lowestEscape;
@property (nonatomic) int highestEscape;

- (id)initWithPoint:(Complex)newPoint;
- (id)initWithPoint:(Complex)newPoint andMaxIterations:(int)newIter;
- (void)doPoint;

@end
