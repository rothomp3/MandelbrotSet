//
//  RTSettingsViewController.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/20/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import "RTSettingsViewController.h"
#import "RTViewController.h"

@implementation RTSettingsViewController
- (IBAction)showMandelbrotSet:(id)sender
{
    [self setNumIterations:[[iterationsField text] intValue]];
    RTViewController* mvc = [[RTViewController alloc] init];
    [mvc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    mvc.numIterations = [self numIterations];
    [[self navigationController] pushViewController:mvc animated:YES];
}
@end
