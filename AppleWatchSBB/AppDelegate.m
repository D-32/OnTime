//
//  AppDelegate.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 01/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MainNavigationController.h"


@implementation AppDelegate {
    NSDateFormatter *_formatter;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MainNavigationController *mainViewController = [[MainNavigationController alloc] init];
    self.window.rootViewController = mainViewController;
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    
    return YES;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    // Temporary fix, I hope.
    // --------------------
    __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
    bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
    });
    // --------------------
    
    __block UIBackgroundTaskIdentifier taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"background task execution run out of time");
        [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
    }];
    if ([userInfo[@"type"] isEqualToString:@"addNotifications"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        NSArray *notifications = userInfo[@"notifications"];
        for (NSDictionary *n in notifications) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [_formatter dateFromString:n[@"time"]];
            notification.alertBody = n[@"message"];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        if (reply) {
            reply(nil);
        }
    } else if ([userInfo[@"type"] isEqualToString:@"clearNotifications"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
}

@end
