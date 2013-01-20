//
//  RTMandlebrotView.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/19/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMandelbrot.h"
#import "RTColorTable.h"

@interface RTMandelbrotView : UIView
@property (strong, nonatomic) RTMandelbrot* mandelbrot;
@property (strong, nonatomic) RTColorTable* colors;
@property (nonatomic) int maxIterations;
@end
