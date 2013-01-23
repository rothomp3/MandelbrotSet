//
//  RTColorTable.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTColorTable : NSObject
@property (strong, nonatomic) NSMutableArray* colors;
@property (nonatomic) int numColors;

- (UIColor*)getColorForInteger:(int)color;
- (id)initWithColors:(int)number;
- (void)generateColors:(int)i;
@end
