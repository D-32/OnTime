//
//  AppDelegate.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 01/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window.rootViewController = mainViewController;
    
    return YES;
}

@end
