//
//  RTColorTable.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct _RTColor
{
    uint8_t red;
    uint8_t green;
    uint8_t blue;
} RTColor;

@interface RTColorTable : NSObject
@property (strong, nonatomic) NSMutableArray* colors;
@property (nonatomic) int numColors;
@property (nonatomic) int startColor;
@property (nonatomic) int endColor;

- (UIColor*)getColorForInteger:(int)color;
- (id)initWithColors:(int)number;

- (id)initWithStartColor:(int)startColor endColor:(int)endColor;

- (RTColor*)getColors;
@end
