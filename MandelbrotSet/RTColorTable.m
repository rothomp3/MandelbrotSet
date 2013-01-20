//
//  RTColorTable.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTColorTable.h"

@implementation RTColorTable
@synthesize colors, numColors;
- (id)initWithColors:(int)number
{
    self = [super init];
    if (self)
    {
        [self setColors:[NSMutableArray new]];
        [self setNumColors:number];
        for (int i = 0; i < numColors; i++)
        {
            CGFloat iFactor = i / (CGFloat)(numColors - 1.0);
            CGFloat hue = iFactor;
            CGFloat saturation = 0.8 + (iFactor * 0.2);
            CGFloat brightness = 1.3 - iFactor;
            
            [colors addObject:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        }
    }
    return self;
}

- (UIColor*)getColorForInteger:(int)color
{
    return colors[color];
}

@end
