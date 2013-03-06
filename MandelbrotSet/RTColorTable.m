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

#define SWAP(a, b) (((a) ^= (b)), ((b) ^= (a)), ((a) ^= (b)))
- (id)initWithStartColor:(int)startColor endColor:(int)endColor
{
    self = [super init];
    if (self)
    {
        self.numColors = 3000;
        //self.colors = [NSMutableArray new];
        colors = malloc(sizeof(RTColor) * self.numColors);
        self.startColor = startColor;
        self.endColor = endColor;
        
        if (startColor > endColor)
            SWAP(startColor, endColor);
        
        int colorCount = 0;
        
        for (float i = startColor; i < endColor; i = i + (float)(endColor - startColor + 1) / (float)numColors)
        {
            CGFloat iFactor = (i) / (CGFloat)(numColors - 1);
            CGFloat hue = iFactor;
            CGFloat saturation = 0.8 + (iFactor * 0.2);
            CGFloat brightness = 1.3 - iFactor;
            
            UIColor* color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
            CGFloat red,green,blue,alpha;
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            colors[colorCount].red = (uint8_t)(ceilf(red * 255.0f));
            colors[colorCount].green = (uint8_t)(ceilf(green * 255.0f));
            colors[colorCount].blue = (uint8_t)(ceilf(blue * 255.0f));
            colorCount++;
        }
        self.numColors = colorCount;
    }
    return self;
}

- (RTColor*)getColors
{
    return colors;
}

- (void)dealloc
{
    NSLog(@"RTColorTable dealloc'ing");
    free(colors);
}
@end
