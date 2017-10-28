//
//  AppDelegate.m
//  Restaurent
//
//  Created by SAN_Technologies on 11/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "STActivityIndicatorView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@property (nonatomic) STActivityIndicatorView *activityIndicator;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [NSThread sleepForTimeInterval:1.0];
    self.activityIndicator = [[[NSBundle mainBundle] loadNibNamed:@"STActivityIndicatorView" owner:self options:nil] objectAtIndex:0];
    [self.activityIndicator setCenter:self.window.center];
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.window addSubview:self.activityIndicator];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)showActivityIndicator
{
    [self.window setUserInteractionEnabled:NO];
    [self.activityIndicator setHidden:NO];
    [self.window bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator showActivity];
}

- (void)stopActivityIndicator
{
    [self.window setUserInteractionEnabled:YES];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopActivity];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)aMessage
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:aMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"OKAY"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                 }];
    [alert addAction:okayButton];
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end