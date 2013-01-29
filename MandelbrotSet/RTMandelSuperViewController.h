//
//  RTMandelSuperViewController.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/25/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTMandelbrotOperation.h"

@class RTColorTable;

@interface RTMandelSuperViewController : UIViewController <UIGestureRecognizerDelegate, RTMandelbrotOperationDelegate>
@property (weak, nonatomic) IBOutlet UILabel *iterationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mandelImage;
@property (strong, atomic) RTMandelbrotOperation* mandelOp;
@property (nonatomic) int maxIterations;
@property (strong, nonatomic) UIViewController* progressController;
@property (nonatomic) BOOL retina;
@property (strong) NSOperationQueue *queue;
@property (strong) RTColorTable* colorTable;
@property BOOL firstAppearance;
@property float currScaleFactor;
@property CGPoint center;

- (void)dismissProgress;
- (void)doTheMandelbrot;
- (float)scaleX:(CGFloat)screenCoord;
- (float)scaleY:(CGFloat)screenCoord;
@end
