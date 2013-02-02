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
{
    float _currScaleFactor;
    NSTimer* saveLabelTimer;
}
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
@property CGPoint center;
@property (weak, nonatomic) IBOutlet UILabel *savedLabel;

- (void)dismissProgress;
- (void)doTheMandelbrot;
- (float)scaleX:(CGFloat)screenCoord;
- (float)scaleY:(CGFloat)screenCoord;

- (IBAction)handlePinch:(UIGestureRecognizer*)gr;
- (void)redoTheMandelbrot:(CGPoint)point zoom:(float)zoomAmount;

- (IBAction)save:(id)sender;

- (void)setCurrScaleFactor:(float)newFactor;
- (float)currScaleFactor;
@end
