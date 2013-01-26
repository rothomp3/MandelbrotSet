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
}

- (IBAction)doOtherThing:(id)sender {
    RTMandelSuperViewController* supermvc = [[RTMandelSuperViewController alloc] initWithNibName:@"RTMandelSuperViewController" bundle:[NSBundle mainBundle] retina:retinaSwitch.on];
    [supermvc setMaxIterations:[[iterationsField text] intValue]];
    [self.view endEditing:YES];
    [[self navigationController] pushViewController:supermvc animated:YES];
}
@end
