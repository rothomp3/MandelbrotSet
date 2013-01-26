//
//  RTMandelbrot.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelbrot.h"
#import <complex.h>

@implementation RTMandelbrot
@synthesize point, maxIterations;
#if USE_PERIODICITY
@synthesize periodTable;
#endif

- (id)initWithPoint:(complex float)newPoint andMaxIterations:(int)newIter
{
    self = [super init];
    [self setPoint:newPoint];
    [self setMaxIterations:newIter];
    
    return self;
}

- (id)initWithPoint:(complex float)newPoint
{
    return [self initWithPoint:newPoint andMaxIterations:0];
}

- (id)init
{
    return [self initWithPoint:0 andMaxIterations:0];
}

- (void)doPoint
{
#if USE_PERIODICITY
    [periodTable clear];
#endif
    float x = crealf(point);
    float y = cimagf(point);
    
    float y2 = y*y;
    float x25 = x - 0.25f;
    float q = x25*x25 + y2;
    float r = q * (q + x25);
    if ((r < (0.25f * y2)) || ((x+1.0f)*(x+1.0f) + y2 < (1.0f / 16.0f)))
    {
        [self setEscapedAt:-1];
        return;
    }
    
    int i = 0;
    complex float z = 0.0f;
    float* zr = (float*)(&z);
    while (((zr[0]*zr[0]+zr[1]*zr[1]) < 4.0f) && (i < maxIterations))
//    while ((cabsf(z) < 2.0f) && (i < maxIterations))
    {
        z = (z * z) + point;
#if USE_PERIODICITY
        if ([periodTable isInTable:z])
        {
            [self setEscapedAt:-1];
            return;
        }
        [periodTable addComplex:z];
#endif
        i++;
    }
    
    if (i == maxIterations)
    {
        // This implies that point is in the set
        [self setEscapedAt:-1];
    }
    else
    {
        [self setEscapedAt:i];
        [self setZn:z];
    }
#if USE_PERIODICITY

#endif
    return;
}

- (void)setMaxIterations:(int)newMax
{
    if (maxIterations != newMax)
    {
        maxIterations = newMax;
#if USE_PERIODICITY
        [self setPeriodTable:nil];
        [self setPeriodTable:[[RTComplexHash alloc] initWithCapacity:maxIterations]];
#endif
    }
}

#if USE_PERIODICITY
- (void)dealloc
{
    if (periodTable != nil)
        periodTable = nil;
}
#endif
@end
