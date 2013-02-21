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
@class RTSettingsViewController;

@interface RTMandelSuperViewController : UIViewController <UIGestureRecognizerDelegate, RTMandelbrotOperationDelegate>
{
    float _currScaleFactor;
    BOOL _shouldAutorotate;
    NSTimer* saveLabelTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *iterationsLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mandelImage;
@property (strong, atomic) RTMandelbrotOperation* mandelOp;
@property (nonatomic) int maxIterations;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel* progressLabel;
@property (nonatomic) BOOL retina;
@property (strong) NSOperationQueue *queue;
@property (strong) RTColorTable* colorTable;
@property BOOL firstAppearance;
@property RTPoint center;
@property (weak, nonatomic) IBOutlet UILabel *savedLabel;

@property (strong, nonatomic) RTSettingsViewController* svc;

@property (nonatomic) int startColor;
@property (nonatomic) int endColor;


- (void)dismissProgress;
- (void)doTheMandelbrot;

- (long double)scaleX:(CGFloat)screenCoord;
- (long double)scaleY:(CGFloat)screenCoord;

- (IBAction)handlePinch:(UIGestureRecognizer*)gr;
- (void)redoTheMandelbrot:(CGPoint)point zoom:(float)zoomAmount;

- (IBAction)save:(id)sender;

- (void)setCurrScaleFactor:(float)newFactor;
- (float)currScaleFactor;

- (IBAction)settings:(id)sender;
@end
