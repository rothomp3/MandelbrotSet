//
//  RTSettingsViewController.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/20/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTSettingsViewController.h"
#import "RTMandelbrotOperation.h"
#import "RTColorTable.h"
#import "RTMandelSuperViewController.h"

@implementation RTSettingsViewController
@synthesize mvc;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:1.0f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if ([UIScreen mainScreen].scale != 2.0f)
    {
        [retinaSwitch setOn:NO];
    }
    [[self sliderLabel] setText:[NSString stringWithFormat:@"%d", (int)[self.iterationsSlider value]]];
}

- (IBAction)doOtherThing:(id)sender {
    RTMandelSuperViewController* supermvc = [[RTMandelSuperViewController alloc] initWithNibName:@"RTMandelSuperViewController" bundle:[NSBundle mainBundle]];
    [supermvc setMaxIterations:(int)[self.iterationsSlider value]]; // set up the iterations
    [supermvc setCenter:CGPointMake(-1.0f, 0.0f)]; // set up the center
    [supermvc setRetina:retinaSwitch.on];
    supermvc.center = CGPointMake([[self.xCoord text] floatValue], [[self.yCoord text] floatValue]);
    [self.view endEditing:YES];
    [[self navigationController] pushViewController:supermvc animated:YES];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [[self sliderLabel] setText:[NSString stringWithFormat:@"%d", (int)[self.iterationsSlider value]]];
}
@end
