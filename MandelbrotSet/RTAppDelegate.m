//
//  RTAppDelegate.m
//  MandelbrotSet
//
//  Created by Robert Stephen Thompson on 11/30/12.
//  Copyright (c) 2012 Robert Stephen Thompson. All rights reserved.
//

#import "RTAppDelegate.h"
//#import "RTSettingsViewController.h"
#import "RTMandelSuperViewController.h"

@implementation RTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //RTSettingsViewController* svc = [[RTSettingsViewController alloc] init];
    RTMandelSuperViewController* msvc = [[RTMandelSuperViewController alloc] initWithNibName:@"RTMandelSuperViewController" bundle:[NSBundle mainBundle]];
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:msvc];
    [[navControl navigationBar] setBarStyle:UIBarStyleBlack];
    [[navControl navigationBar] setTranslucent:YES];
    //[[self window] setRootViewController:mvc];
    [[self window] setRootViewController:navControl];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
		
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
