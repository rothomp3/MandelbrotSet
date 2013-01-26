//
//  RTSettingsViewController.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/20/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTViewController;
@interface RTSettingsViewController : UIViewController <UIPopoverControllerDelegate>
{
    IBOutlet UITextField* iterationsField;
    __weak IBOutlet UISwitch *retinaSwitch;
    
    UIPopoverController* imagePopover;
}
@property (nonatomic) int numIterations;
@property (strong, nonatomic) RTViewController* mvc;
@property (strong, nonatomic) UIViewController* pc;

- (IBAction)doOtherThing:(id)sender;

@end
