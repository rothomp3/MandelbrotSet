//
//  RTSettingsViewController.h
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 1/20/13.
//  Copyright (c) 2013 Robert Stephen Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTSettingsViewController : UIViewController
{
    IBOutlet UITextField* iterationsField;
}
@property (nonatomic) int numIterations;

- (IBAction)showMandelbrotSet:(id)sender;

@end
