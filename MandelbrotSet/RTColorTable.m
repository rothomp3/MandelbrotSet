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
    return [self initWithStartColor:0 endColor:number - 1];
}

- (UIColor*)getColorForInteger:(int)color
{
    return colors[color];
}

#define SWAP(a, b) (((a) ^= (b)), ((b) ^= (a)), ((a) ^= (b)))
- (id)initWithStartColor:(int)startColor endColor:(int)endColor
{
    self = [super init];
    if (self)
    {
        self.numColors = 3000;
        self.colors = [NSMutableArray new];
        self.startColor = startColor;
        self.endColor = endColor;
        
        if (startColor > endColor)
            SWAP(startColor, endColor);
        
        for (float i = startColor; i < endColor; i = i + (float)(endColor - startColor + 1) / (float)numColors)
        {
            CGFloat iFactor = (i) / (CGFloat)(numColors - 1);
            CGFloat hue = iFactor;
            CGFloat saturation = 0.8 + (iFactor * 0.2);
            CGFloat brightness = 1.3 - iFactor;
            
            [colors addObject:[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0]];
        }
        self.numColors = colors.count;
    }
    return self;
}

- (RTColor*)getColors // returns an array of RTColors. The user must free the memory manually :P
{
    RTColor* colorPtrs = malloc(sizeof(RTColor) * self.numColors);
    CGFloat red, green, blue, alpha;
    for (int i = 0; i < self.numColors; i++)
    {
        [self.colors[i] getRed:&red green:&green blue:&blue alpha:&alpha];
        colorPtrs[i].red = (uint8_t)(ceilf(red * 255.0f));
        colorPtrs[i].green = (uint8_t)(ceilf(green * 255.0f));
        colorPtrs[i].blue = (uint8_t)(ceilf(blue * 255.0f));
    }
    
    return colorPtrs;
}
@end
