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
            /*
            int8_t red = (int8_t)i;
            int8_t green = (int8_t)(i >> 8);
            int8_t blue = (int8_t)(i >> 16);
            CGFloat redf = red / 255.0;
            CGFloat greenf = green / 255.0;
            CGFloat bluef = blue / 255.0;
            */
            CGFloat redf = (1.0 - ((i * 10) / (CGFloat)(numColors -1.0))) - 0.2;
            CGFloat greenf = (1.0 - ((i * 5) / (CGFloat)(numColors -1.0))) - 0.2;
            CGFloat bluef = 1.0 - i / (CGFloat)(numColors -1.0);
            [colors addObject:[UIColor colorWithRed:redf green:greenf blue:bluef alpha:1.0]];
        }
    }
    return self;
}

- (UIColor*)getColorForInteger:(int)color
{
    return colors[color];
}

@end
