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

@interface RTMandelSuperViewController ()

@end

@implementation RTMandelSuperViewController
@synthesize queue, colorTable, currScaleFactor, center;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil retina:(BOOL)ret
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.retina = ret;
        queue = [[NSOperationQueue alloc] init];
        self.firstAppearance = YES;
        currScaleFactor = self.retina?200.0f:100.0f;
        center = CGPointMake(-1.0f, 0.0f);
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil retina:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    colorTable = [[RTColorTable alloc] initWithColors:500];
    self.progressController = [[UIViewController alloc] initWithNibName:@"progressBar" bundle:[NSBundle mainBundle]];   
    //[self doTheMandelbrot];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.mandelOp = nil;
    self.colorTable = nil;
    self.progressController = nil;
}

- (IBAction)handleGesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:[self view]];
    
    //translate the y coordinate to CGContextland
    point.y = (point.y - self.view.bounds.size.height) * -1.0f;
    
    if (self.retina)
    {
        point.x *= 2.0f;
        point.y *= 2.0f;
    }
    
    center.x = [self scaleX:point.x];
    center.y = [self scaleY:point.y];

    if ([sender numberOfTouches] < 2)
        currScaleFactor *= 2.0f;
    else
        currScaleFactor /= 2.0f;
    
    [self doTheMandelbrot];
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
    [self.mandelOp setColorTable:[[colorTable colors] copy]];
    [self.mandelOp setProgress:(UIProgressView*)[self.progressController.view viewWithTag:314]];
    [self.mandelOp setProgressLabel:(UILabel*)[self.progressController.view viewWithTag:10]];
    [self.mandelOp setDelegate:self];
    
    [self.mandelOp setCenter:center];
    [self.mandelOp setCurrScaleFactor:currScaleFactor];

    [queue addOperation:self.mandelOp];
    
    [self.iterationsLabel setText:[NSString stringWithFormat:@"%d iterations", self.maxIterations]];
    [self.zoomLabel setText:[NSString stringWithFormat:@"Zoom: %.1fx", self.mandelOp.currScaleFactor / (self.retina?200.0f:100.0f)]];
    
    [[self navigationController] pushViewController:self.progressController animated:NO] ;
}

- (float)scaleX:(CGFloat)screenCoord
{
    CGFloat screenCenter = self.view.bounds.size.width;
    
    if (!self.retina)
        screenCenter /= 2.0f;
    
    return ((float)screenCoord - (float)(screenCenter))/currScaleFactor + (float)(center.x);
}

- (float)scaleY:(CGFloat)screenCoord
{
    CGFloat screenCenter = self.view.bounds.size.height;

    if (!self.retina)
        screenCenter /= 2.0f;
    
    return (0.0f - ((float)screenCoord - (float)(screenCenter)))/currScaleFactor + (float)(center.y);
}
@end