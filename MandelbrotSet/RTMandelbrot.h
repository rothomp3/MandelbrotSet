//
//  RTMandelbrot.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <complex.h>
#define USE_PERIODICITY 0

#if USE_PERIODICITY
#import "RTComplexHash.h"
#endif

@interface RTMandelbrot : NSObject

@property complex float point;
@property (nonatomic) int maxIterations;
@property int escapedAt;
@property complex float zn;
#if USE_PERIODICITY
@property (strong) RTComplexHash* periodTable;
#endif

- (id)initWithPoint:(float _Complex)newPoint;
- (id)initWithPoint:(float _Complex)newPoint andMaxIterations:(int)newIter;
- (void)doPoint;

@end
