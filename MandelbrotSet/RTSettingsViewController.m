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
    self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.translucent = NO;
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
    self.displayX = [NSString stringWithFormat:@"%.2Lf",self.x];
    [self.xCoord setText:self.displayX];
    self.displayY = [NSString stringWithFormat:@"%.2Lf",self.y];
    [self.yCoord setText:self.displayY];
    [self.zoom setText:[NSString stringWithFormat:@"%.3f", self.zoomValue]];
    
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
    self.navigationController.navigationBar.translucent = YES;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [[self sliderLabel] setText:[NSString stringWithFormat:@"%d", (int)[self.iterationsSlider value]]];
    [self valuesChanged:sender];
}

- (IBAction)dismissKeyboard:(UIView *)sender {
    [self.view endEditing:YES];
}

- (IBAction)valuesChanged:(id)sender
{
    [supermvc setMaxIterations:(int)[self.iterationsSlider value]]; // set up the iterations
    [supermvc setRetina:retinaSwitch.on]; // set up retina
    RTPoint newCenter = { 0, 0 };
    if (![[self.xCoord text] isEqualToString:self.displayX])
        newCenter.x = [self.xCoord.text doubleValue];
    else
        newCenter.x = self.x;
    if (![self.yCoord.text isEqualToString:self.displayY])
        newCenter.y = [self.yCoord.text doubleValue];
    else
        newCenter.y = self.y;
    supermvc.center = newCenter;
    [supermvc setCurrScaleFactor:[[self.zoom text] floatValue]];
    [supermvc setStartColor:(int)self.startColorSlider.value];
    [supermvc setEndColor:(int)self.endColorSlider.value];
    if (supermvc.mandelImage.image != nil)
        supermvc.mandelImage.image = nil;
}

- (IBAction)changeColor:(UIControl *)sender
{
    UISlider* slider = (UISlider*)sender;
    CGFloat colorNumber = slider.value / 1999.0f;
    CGFloat hue = colorNumber;
    CGFloat saturation = 0.8f + (colorNumber * 0.2f);
    CGFloat brightness = 1.3f - colorNumber;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
    if ([sender tag] == 1)
        self.colorSquare.backgroundColor = color;
    else
        self.colorSquare2.backgroundColor = color;
    [self valuesChanged:self];
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
