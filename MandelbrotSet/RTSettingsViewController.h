//
//  RTSettingsViewController.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/20/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTMandelSuperViewController;
@interface RTSettingsViewController : UIViewController <UIPopoverControllerDelegate>
{
    __weak IBOutlet UISwitch *retinaSwitch;
}

@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;
@property (weak, nonatomic) IBOutlet UISlider *iterationsSlider;
@property (weak, nonatomic) IBOutlet UITextField *xCoord;
@property (weak, nonatomic) IBOutlet UITextField *yCoord;
@property (weak, nonatomic) IBOutlet UITextField *zoom;
@property (weak, nonatomic) RTMandelSuperViewController* supermvc;
// Properties for setting up the mandelbrot
@property (nonatomic) int numIterations;
@property (nonatomic) long double x;
@property (nonatomic) long double y;
@property (nonatomic) float zoomValue;

- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)dismissKeyboard:(UIView *)sender;
- (IBAction)valuesChanged:(id)sender;

@end
