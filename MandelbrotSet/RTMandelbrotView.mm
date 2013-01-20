//
//  RTMandlebrotView.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelbrotView.h"
#include "complex.h"

@implementation RTMandelbrotView
@synthesize mandelbrot, colors, maxIterations;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setMandelbrot:[[RTMandelbrot alloc] init]];
        [self setColors:[[RTColorTable alloc] initWithColors:256]];
        NSLog(@"Init complete, including colors.");
    }
    return self;
}
- (void)drawRect:(CGRect)dirtyRect
{
    [mandelbrot setMaxIterations:maxIterations];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bounds = [self bounds];
    
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    CGContextSetLineWidth(ctx, 0.0);
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.0);
    for (float i = 0; i < bounds.size.width; i+=0.5)
    {
        for (float j = 0; j < bounds.size.height; j+=0.5)
        {
            double x = (i - center.x) / 100.0 - 1.0;
            double y = (0.0 - (j - center.y)) / 100.0;
            
            [mandelbrot setPoint:Complex(x,y)];
            [mandelbrot doPoint];
            if ([mandelbrot isInSet])
            {
                CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
            }
            else
            {
                [[colors colors][[mandelbrot escapedAt] % [colors numColors]] setFill];
            }
            
            CGContextFillRect(ctx, CGRectMake(i, j, 1.0, 1.0));
        }
    }
    NSString* iterationsString = [NSString stringWithFormat:@"%d iterations", [mandelbrot maxIterations]];
    UIFont* font = [UIFont boldSystemFontOfSize:12.0];
    CGRect iterationsRect;
    iterationsRect.size = [iterationsString sizeWithFont:font];
    iterationsRect.origin.x = 5.0;
    iterationsRect.origin.y = iterationsRect.size.height / 2.0;
    
    [[UIColor blackColor] setFill];
    
    CGSize offset = CGSizeMake(2, 1.5);
    CGColorRef shadowColor = [[UIColor darkGrayColor] CGColor];
    CGContextSetShadowWithColor(ctx, offset, 2.0, shadowColor);
    
    [iterationsString drawInRect:iterationsRect withFont:font];
}
@end
