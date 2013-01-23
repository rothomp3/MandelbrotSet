//
//  RTColorTable.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTColorTable.h"

static const int colorLoops = 1;

@implementation RTColorTable
@synthesize colors, numColors;
- (id)initWithColors:(int)number
{
    self = [super init];
    if (self)
    {
        [self setColors:[NSMutableArray new]];
        [self setNumColors:number];
        for (int j = 0; j < colorLoops; j++)
        {
            for (int i = 0; i < (numColors/colorLoops); i++)
            {
                [self generateColors:i];
            }
        }
    }
    return self;
}

- (UIColor*)getColorForInteger:(int)color
{
    return colors[color];
}

- (void)generateColors:(int)i
{
    CGFloat iFactor = (i) / (numColors/colorLoops  - 1.0);
    CGFloat hue = iFactor;//0.58 + (iFactor * 0.2);
    CGFloat saturation = 0.8 + (iFactor * 0.2);
    CGFloat brightness = 1.3 - iFactor;
    
    [colors addObject:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
}
@end
