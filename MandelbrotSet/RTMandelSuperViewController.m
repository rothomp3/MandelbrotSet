//
//  RTMandelSuperViewController.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/25/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTMandelSuperViewController.h"
#import "RTMandelbrotOperation.h"
#import "RTMandelbrot.h"
#import "RTColorTable.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "UIKit/UIView.h"

@interface RTMandelSuperViewController ()

@end

@implementation RTMandelSuperViewController
@synthesize queue, colorTable, center;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.retina = ([UIScreen mainScreen].scale<2.0)?NO:YES;
        queue = [[NSOperationQueue alloc] init];
        self.firstAppearance = YES;
        colorTable = [[RTColorTable alloc] initWithColors:2000];
        self.progressController = [[UIViewController alloc] initWithNibName:@"progressBar" bundle:[NSBundle mainBundle]];
        [self.progressController.view setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:1.0f alpha:1.0f]];
        
        UIBarButtonItem* editItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        [self.navigationItem setRightBarButtonItem:editItem];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.firstAppearance)//if this is the first time we've seen this view
    {        
        self.firstAppearance = NO;
        [self doTheMandelbrot];
    }
}

- (float)currScaleFactor
{
    return _currScaleFactor;
}

- (void)setCurrScaleFactor:(float)newFactor
{
    _currScaleFactor = newFactor * (self.retina?200.0f:100.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.mandelOp = nil;
    self.colorTable = nil;
    self.progressController = nil;
    saveLabelTimer = nil;
}

- (IBAction)handleGesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:[self view]];
    //float zoomAmount = 2;
    //if ([sender numberOfTouches] > 1)
    //    zoomAmount = 0.5;
    float zoomAmount = 1;//tapping just recenters the plot
    
    [self redoTheMandelbrot:point zoom:zoomAmount];
}

- (void)dismissProgress
{
    [self.mandelImage setImage:self.mandelOp.result];
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)doTheMandelbrot
{
    self.mandelOp = nil; // make sure the old one, if it exists, gets freed
    
    CGRect mandelBounds = self.view.bounds;
    
    self.mandelOp = [[RTMandelbrotOperation alloc] initWithBounds:mandelBounds retina:self.retina];
    [self.mandelOp setMaxIterations:[self maxIterations]];
    [self.mandelOp setColorTable:[colorTable colors]];
    [self.mandelOp setProgress:(UIProgressView*)[self.progressController.view viewWithTag:314]];
    [self.mandelOp setProgressLabel:(UILabel*)[self.progressController.view viewWithTag:10]];
    [self.mandelOp setDelegate:self];
    
    [self.mandelOp setCenter:center];
    [self.mandelOp setCurrScaleFactor:_currScaleFactor];

    [queue addOperation:self.mandelOp];
    
    [self.iterationsLabel setText:[NSString stringWithFormat:@"%d iterations", self.maxIterations]];
    [self.zoomLabel setText:[NSString stringWithFormat:@"Zoom: %.1fx", self.mandelOp.currScaleFactor / (self.retina?200.0f:100.0f)]];
    
    [[self navigationController] pushViewController:self.progressController animated:NO] ;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"gesture.scale = %f", gesture.scale);
        
        CGFloat currentScale = self.view.frame.size.width / self.view.bounds.size.width;
        CGFloat newScale = currentScale * gesture.scale;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        self.view.transform = transform;
        gesture.scale = 1;
        
        if (gesture.state == UIGestureRecognizerStateEnded)
        {
            //CGPoint point = [gesture locationInView:self.view];
            //float zoomAmount;
            //zoomAmount = newScale;
            //[self redoTheMandelbrot:point zoom:zoomAmount];
            self.view.transform = CGAffineTransformIdentity;
            _currScaleFactor *= newScale;
            [self.mandelImage setImage:nil];
            [self doTheMandelbrot];
        }
    }
}

- (long double)scaleX:(CGFloat)screenCoord
{
    long double screenCenter = self.view.bounds.size.width;
    
    if (!self.retina)
        screenCenter /= 2.0f;
    
    return ((long double)screenCoord - screenCenter)/(long double)_currScaleFactor + (long double)(center.x);
}

- (long double)scaleY:(CGFloat)screenCoord
{
    long double screenCenter = self.view.bounds.size.height;

    if (!self.retina)
        screenCenter /= 2.0f;
    
    return (0.0l - ((long double)screenCoord - screenCenter))/(long double)_currScaleFactor + center.y;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self doTheMandelbrot];
}

- (void)redoTheMandelbrot:(CGPoint)point zoom:(float)zoomAmount
{
    self.view.transform = CGAffineTransformIdentity; // set the view back to normal before drawing again
    
    //translate the y coordinate to CGContextland
    point.y = (point.y - self.view.bounds.size.height) * -1.0f;
    
    if (self.retina)
    {
        point.x *= 2.0f;
        point.y *= 2.0f;
    }
    
    center.x = [self scaleX:point.x];
    center.y = [self scaleY:point.y];
    
    _currScaleFactor *= zoomAmount;
    
    [self.mandelImage setImage:nil];
    [self doTheMandelbrot];
}

- (IBAction)save:(id)sender
{
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[self.mandelImage.image CGImage] metadata:@{@"orientation":[NSNumber numberWithInt:[self.mandelImage.image imageOrientation]], @"center.x":[NSNumber numberWithFloat:self.center.x], @"center.y":[NSNumber numberWithFloat:self.center.y] } completionBlock:^(NSURL *assetUrl, NSError* error) {
        [UIView animateWithDuration:0.25 animations:^(void) { self.savedLabel.hidden = NO; self.savedLabel.alpha = 1.0; } completion:^(BOOL finished) {}];
    }];
    saveLabelTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(clearSavedText) userInfo:nil repeats:NO];
}

- (void)clearSavedText
{
    [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) { self.savedLabel.alpha = 0.0; } completion:^(BOOL finished) { self.savedLabel.hidden = YES; }];
}
@end
