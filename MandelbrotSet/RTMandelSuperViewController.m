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
#import "RTSettingsViewController.h"

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

        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.hidden = YES;
        self.progressView.progress = 0.0f;
        
        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.hidden = YES;
        self.progressLabel.text = @"";
        self.progressLabel.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:self.progressView];
        [self.view addSubview:self.progressLabel];
        
        UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        [self.navigationItem setRightBarButtonItem:saveItem];
        
        UIBarButtonItem* settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"⚙" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
        UIFont* font = [UIFont systemFontOfSize:24.0f];
        [settingsItem setTitleTextAttributes:@{UITextAttributeFont:font} forState:UIControlStateNormal];
        [self.navigationItem setLeftBarButtonItem:settingsItem];
        
        self.navigationItem.title = @"MandelbrotSet";
        
        // Set up some intelligent defaults
        self.maxIterations = 300;
        self.currScaleFactor = 1.0;
        self.center = RTPointMake(-1.0l, 0.0l);
        self.startColor = 0;
        self.endColor = 1999;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.firstAppearance)//if this is the first time we've seen this view
    {        
        self.firstAppearance = NO;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
                self.mandelImage.image = [UIImage imageNamed:@"startermandel-ipad-landscape.JPG"];
            else
                self.mandelImage.image = [UIImage imageNamed:@"startermandel-ipad.JPG"];
        }
        else if (self.view.bounds.size.height > 480)// if we're on a big iPhone
            self.mandelImage.image = [UIImage imageNamed:@"startermandel-568h.jpg"];
        else
            self.mandelImage.image = [UIImage imageNamed:@"startermandel.jpg"];
        
        self.iterationsLabel.text = @"300 Iterations";
        self.zoomLabel.text = @"1.0x";
    }
    else if (self.mandelImage.image == nil) // should only happen after a low memory warning
        [self doTheMandelbrot];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (float)currScaleFactor
{
    return _currScaleFactor / (self.retina?200.0f:100.0f);
}

- (float)realScaleFactor
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
    saveLabelTimer = nil;
    self.mandelImage.image = nil;
    self.svc = nil;
}

- (IBAction)handleGesture:(UITapGestureRecognizer *)sender {
    if ([sender numberOfTouches] > 1)
    {
        if (self.navigationController.navigationBarHidden)
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        else
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        return;
    }
    CGPoint point = [sender locationInView:[self view]];
    float zoomAmount = 1;//tapping just recenters the plot
    
    [self redoTheMandelbrot:point zoom:zoomAmount];
}

- (void)dismissProgress
{
    UIImage* theImage;
    if (self.mandelOp.result == nil)
    {
        NSData* imageData = [NSData dataWithContentsOfFile:[self imageCachePath]];
        if (imageData == nil)
        {
            NSLog(@"error reading image data");
        }
        theImage = [UIImage imageWithData:imageData];
        NSLog(@"Loading image: %@", theImage);
    }
    else
    {
        theImage = self.mandelOp.result;
    }
    self.mandelImage.image = nil;
    [self.mandelImage setImage:theImage];
    self.progressView.hidden = YES;
    self.progressLabel.hidden = YES;
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    self.singleTap.enabled = YES;
    self.doubleTap.enabled = YES;
    self.pinch.enabled = YES;
}

- (NSString*)imageCachePath
{
    NSArray* cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = cacheDirectories[0];
    return [cacheDirectory stringByAppendingPathComponent:@"cache.png"];
}

- (void)doTheMandelbrot
{
    self.singleTap.enabled = NO;
    self.doubleTap.enabled = NO;
    self.pinch.enabled = NO;
    if (self.mandelImage.image != nil)
    {
        NSData* imageData = UIImagePNGRepresentation(self.mandelImage.image);
        [imageData writeToFile:[self imageCachePath] atomically:YES];
        [self.mandelImage setImage:nil];
    }
    self.mandelOp = nil; // make sure the old one, if it exists, gets freed
    
    if (self.colorTable.startColor != self.startColor || self.colorTable.endColor != self.endColor)
    {
        self.colorTable = nil;
        self.colorTable = [[RTColorTable alloc] initWithStartColor:self.startColor endColor:self.endColor];
    }
    
    CGRect mandelBounds = self.view.bounds;
    
    self.mandelOp = [[RTMandelbrotOperation alloc] initWithBounds:mandelBounds retina:self.retina];
    [self.mandelOp setMaxIterations:[self maxIterations]];
    [self.mandelOp setColorTable:colorTable];
    [self.mandelOp setProgress:self.progressView];
    [self.mandelOp setProgressLabel:self.progressLabel];
    [self.mandelOp setDelegate:self];
    
    [self.mandelOp setCenter:center];
    [self.mandelOp setCurrScaleFactor:_currScaleFactor];

    [queue addOperation:self.mandelOp];
    
    [self.iterationsLabel setText:[NSString stringWithFormat:@"%d iterations", self.maxIterations]];
    [self.zoomLabel setText:[NSString stringWithFormat:@"Zoom: %.1fx", self.mandelOp.currScaleFactor / (self.retina?200.0f:100.0f)]];
    
    // Set up the progress bar display
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    self.progressLabel.center = CGPointMake(self.view.center.x, self.view.center.y + 10.0f);
    self.progressView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width - 40.0f, self.progressView.bounds.size.height);
    self.progressView.center = self.view.center;
    self.progressView.progress = 0.0f;
    self.progressView.hidden = NO;
    self.progressLabel.hidden = NO;
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
    if (![self.mandelOp isExecuting])
    {
        [self doTheMandelbrot];
    }
    else
    {
        [self.mandelOp cancel];
        [self dismissProgress];
    }
}

- (void)redoTheMandelbrot:(CGPoint)point zoom:(float)zoomAmount
{
    self.view.transform = CGAffineTransformIdentity; // set the view back to normal before drawing again
    
    if (self.retina)
    {
        point.x *= 2.0f;
        point.y *= 2.0f;
    }
    
    center.x = [self scaleX:point.x];
    center.y = [self scaleY:point.y];
    
    _currScaleFactor *= zoomAmount;
    
    //[self.mandelImage setImage:nil];
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

- (IBAction)settings:(id)sender
{
    if (self.svc == nil)
    {
        // Create the settings view controller
        self.svc = [[RTSettingsViewController alloc] initWithNibName:@"RTSettingsViewController" bundle:[NSBundle mainBundle]];
    }
    self.svc.supermvc = self;
    self.svc.zoomValue = [self currScaleFactor];
    self.svc.x = self.center.x;
    self.svc.y = self.center.y;
    self.svc.numIterations = self.maxIterations;
    [[self navigationController] pushViewController:self.svc animated:YES];
}

- (void)setShouldAutorotate:(BOOL)shouldAutrotate
{
    _shouldAutorotate = shouldAutrotate;
}

- (BOOL)shouldAutorotate
{
    NSLog(@"shouldAutorotate called");
    if (self.progressView.hidden == NO)
        return NO;
    else return YES;
}

- (void)updateImage:(UIImage *)newImage
{
  self.mandelImage.image = newImage;    
}

@end
