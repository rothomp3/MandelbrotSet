//
//  RTMandelbrot.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelbrot.h"
#include "mycomplex.h"

@implementation RTMandelbrot
@synthesize point, maxIterations;
- (id)initWithPoint:(Complex)newPoint andMaxIterations:(int)newIter
{
    self = [super init];
    [self setPoint:newPoint];
    [self setMaxIterations:newIter];
    [self setLowestEscape:maxIterations];
    
    return self;
}

- (id)initWithPoint:(Complex)newPoint
{
    return [self initWithPoint:newPoint andMaxIterations:10000];
}

- (id)init
{
    return [self initWithPoint:Complex(0.0l, 0.0l) andMaxIterations:10000];
}

- (void)doPoint
{
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
    while ((z.abs() < 2) && (i < maxIterations))
    {
        z = (z * z) + point;
        i++;
    }
    
    if (i == maxIterations)
    {
        // This implies that point is in the set
        [self setEscapedAt:-1];
    }
    else
    {
        if (i < [self lowestEscape])
            [self setLowestEscape:i];
        if (i > [self highestEscape])
            [self setHighestEscape:i];
        [self setEscapedAt:i];
    }
    return;
}
@end
