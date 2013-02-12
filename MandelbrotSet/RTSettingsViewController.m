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
#import "UIKit/UIView.h"

@implementation RTSettingsViewController
@synthesize supermvc;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.9f green:0.9f blue:1.0f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if ([UIScreen mainScreen].scale != 2.0f)
    {
        [retinaSwitch setOn:NO];
    }
    self.iterationsSlider.value = self.numIterations;
    [[self sliderLabel] setText:[NSString stringWithFormat:@"%d", (int)[self.iterationsSlider value]]];
    [self.xCoord setText:[NSString stringWithFormat:@"%.2Lf",self.x]];
    [self.yCoord setText:[NSString stringWithFormat:@"%.2Lf",self.y]];
    [self.zoom setText:[NSString stringWithFormat:@"%.3f", self.zoomValue]];
}

- (IBAction)doOtherThing:(id)sender {
    [supermvc setMaxIterations:(int)[self.iterationsSlider value]]; // set up the iterations
    [supermvc setCenter:RTPointMake(-1.0f, 0.0f)]; // set up the center
    [supermvc setRetina:retinaSwitch.on];
    supermvc.center = RTPointMake([[self.xCoord text] doubleValue], [[self.yCoord text] doubleValue]);
    [supermvc setCurrScaleFactor:[[self.zoom text] floatValue]];
    [self.view endEditing:YES];
    
    //[[self navigationController] pushViewController:supermvc animated:YES];
    [self.navigationController popViewControllerAnimated:NO];
    [self.supermvc doTheMandelbrot];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [[self sliderLabel] setText:[NSString stringWithFormat:@"%d", (int)[self.iterationsSlider value]]];
}

- (IBAction)dismissKeyboard:(UIView *)sender {
    [self.view endEditing:YES];
}

#define kOFFSET_FOR_KEYBOARD 100.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if (TRUE)
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) { 
        CGRect rect = self.view.frame;
        if (movedUp)
        {
            // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
            // 2. increase the size of the view so that the area behind the keyboard is covered up.
            rect.origin.y -= kOFFSET_FOR_KEYBOARD;
            rect.size.height += kOFFSET_FOR_KEYBOARD;
        }
        else
        {
            // revert back to the normal state.
            rect.origin.y += kOFFSET_FOR_KEYBOARD;
            rect.size.height -= kOFFSET_FOR_KEYBOARD;
        }
        self.view.frame = rect;
    } completion:nil];
}

@end
