//
//  RTMandelbrot.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelbrot.h"
#include "complex.h"

@implementation RTMandelbrot
@synthesize point, maxIterations;
#if USE_PERIODICITY
@synthesize visitedSet, numTimesPeriodicityHelped;
#endif

- (id)initWithPoint:(Complex)newPoint andMaxIterations:(int)newIter
{
    self = [super init];
    [self setPoint:newPoint];
    [self setMaxIterations:newIter];
    [self setZabs:-1.0];
    return self;
}

- (id)initWithPoint:(Complex)newPoint
{
    return [self initWithPoint:newPoint andMaxIterations:1];
}

- (id)init
{
    return [self initWithPoint:Complex(0.0, 0.0) andMaxIterations:1];
}

- (id)initWithMaxIterations:(int)newIter
{
    return [self initWithPoint:Complex(0,0) andMaxIterations:newIter];
}

- (void)doPoint
{
#if USE_PERIODICITY
    visitedSet.clear();
#endif
    [self setZabs:-1.0];
    double x = point.getRealPart();
    double y = point.getImaginaryPart();
    
    double y2 = y*y;
    double x25 = x - 0.25;
    double q = x25*x25 + y2;
    double r = q * (q + x25);
    if ((r < (0.25 * y2)) || ((x+1.0)*(x+1.0) + y2 < (1.0 / 16.0)))
    {
        [self setEscapedAt:-1];
        return;
    }
    
    int i = 0;
    Complex z(0,0);
    while ((z.abs2() < 4) && (i < maxIterations))
    {
        //z = (z * z) + point;
        z *= z;
        z += point;
        // Doing it that way was a significant optimization, apparently
#if USE_PERIODICITY
        if([self isInValues:z])
        {
            [self setEscapedAt:-1];
            numTimesPeriodicityHelped++;
            return;
        }
        else
        {
            visitedSet.insert(z);
        }
#endif
        i++;
    }
    
    if (i == maxIterations)
    {
        // This implies that point is in the set
        [self setEscapedAt:-1];
        return;
    }
    else
    {
        [self setEscapedAt:i];
    }
    [self setLastZ:z];
    return;
}

- (void)setMaxIterations:(int)newMax
{
    if (newMax != maxIterations)
    {
#if USE_PERIODICITY
        visitedSet.clear();
        visitedSet.reserve(newMax * 8);
#endif
        maxIterations = newMax;
    }
}

- (BOOL)isInValues:(Complex)value
{
#if USE_PERIODICITY
    if (visitedSet.find(value) != visitedSet.end())
        return YES;
#endif
    return NO;
}

- (void)setLastZ:(Complex)newZ
{
    if (_lastZ != newZ)
    {
        _lastZ = newZ;
        _zabs = self.lastZ.abs();
    }
}

@end
