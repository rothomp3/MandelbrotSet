//
//  RTMandelbrot.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "complex.H"

#define USE_PERIODICITY 0

#if USE_PERIODICITY
#include <unordered_set>
#endif
@interface RTMandelbrot : NSObject

@property (nonatomic) Complex point;
@property (nonatomic) int maxIterations;
@property (nonatomic) int escapedAt;
@property (nonatomic) Complex lastZ;
@property (nonatomic) double zabs;
#if USE_PERIODICITY
@property (nonatomic) std::unordered_set<Complex> visitedSet;
@property (nonatomic) int numTimesPeriodicityHelped;
#endif

- (id)initWithPoint:(Complex)newPoint;
- (id)initWithPoint:(Complex)newPoint andMaxIterations:(int)newIter;
- (id)initWithMaxIterations:(int)newIter;
- (void)doPoint;
- (BOOL)isInValues:(Complex)value;
@end
