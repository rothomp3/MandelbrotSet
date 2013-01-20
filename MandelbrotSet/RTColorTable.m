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
            CGFloat divisor = (CGFloat)(numColors - 1.0);
            CGFloat redf = (1.0 - (i / divisor)) - 0.2;
            CGFloat greenf = (1.0 - (i / divisor)) - 0.2;
            CGFloat bluef = 1.0 - i / divisor;
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
