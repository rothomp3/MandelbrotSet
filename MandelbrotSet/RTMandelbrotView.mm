//
//  RTMandlebrotView.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelbrotView.h"
#include "mycomplex.h"

@implementation RTMandelbrotView
@synthesize mandelbrot, colors, maxIterations, currScaleFactor, center, screenCenter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setMandelbrot:[[RTMandelbrot alloc] init]];
        [self setColors:[[RTColorTable alloc] initWithColors:32]];
        [self setCurrScaleFactor:100];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        
        [self addGestureRecognizer:tapRecognizer];

        center.x = -1.0;
        center.y = 0.0;
        NSLog(@"Init complete, including colors.");
    }
    return self;
}
- (void)drawRect:(CGRect)dirtyRect
{
    [mandelbrot setMaxIterations:maxIterations];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bounds = [self bounds];
    
    CGContextSetLineWidth(ctx, 0.0);
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.0);

    NSArray* colorTable = [colors colors];
    screenCenter.x = self.bounds.size.width / 2.0;
    screenCenter.y = self.bounds.size.height / 2.0;
    
    for (CGFloat i = 0; i < bounds.size.width; i+=0.5)
    {
        for (CGFloat j = 0; j < bounds.size.height; j+=0.5)
        {            
            [mandelbrot setPoint:Complex([self scaleX:i], [self scaleY:j])];
            [mandelbrot doPoint];
            if ([mandelbrot escapedAt] == -1)
            {
                CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
            }
            else
            {
                unsigned int colorIndex = [mandelbrot escapedAt] % [colors numColors];
                [colorTable[colorIndex] setFill];
            }
            
            CGContextFillRect(ctx, CGRectMake(i, j, 0.5, 0.5));
        }
    }
    NSString* iterationsString = [NSString stringWithFormat:@"MaxIterations: %d", [mandelbrot maxIterations]];
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

- (double)scaleX:(CGFloat)screenCoord
{
    return (screenCoord - screenCenter.x)/currScaleFactor + center.x;
}

- (double)scaleY:(CGFloat)screenCoord
{
    return (0.0 - (screenCoord - screenCenter.y))/currScaleFactor + center.y;
}

- (void)tap:(UIGestureRecognizer*)gr
{
    [self setCurrScaleFactor:currScaleFactor * 2];
    CGPoint point = [gr locationInView:self];
    CGPoint scaledPoint;
    scaledPoint.x = [self scaleX:point.x];
    scaledPoint.y = [self scaleY:point.y];
    NSLog(@"New center is at (%f, %f)", scaledPoint.x, scaledPoint.y);
    [self setCenter:scaledPoint];
    [self setNeedsDisplay];
}
@end
