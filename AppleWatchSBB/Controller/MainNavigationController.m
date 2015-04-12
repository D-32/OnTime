//
//  MainNavigationController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 12.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "MainNavigationController.h"
#import "MainViewController.h"

@implementation MainNavigationController

- (instancetype)init {
    if (self = [super init]) {
        MainViewController *vc = [[MainViewController alloc] init];
        [self pushViewController:vc animated:NO];
    }
    return self;
}

@end
