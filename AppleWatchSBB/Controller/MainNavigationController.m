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
        
        UINavigationBar *navigationBar = self.navigationBar;
        [navigationBar setBackgroundImage:[self gradientGreenColorImage]
                            forBarMetrics:UIBarMetricsDefault];
        [navigationBar setShadowImage:[[UIImage alloc] init]];
        [navigationBar setBarTintColor:nil];
        [navigationBar setTintColor:[UIColor whiteColor]];
        [navigationBar setTitleTextAttributes:@{
                                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                                }];
        
        MainViewController *vc = [[MainViewController alloc] init];
        [self pushViewController:vc animated:NO];
    }
    return self;
}

- (UIImage *)gradientGreenColorImage {
    UIImage *gradientImage = nil;
    CGRect bounds = {.size = {320, 3}};
    UIGraphicsBeginImageContextWithOptions(bounds.size , NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        CGFloat locations[2] = {0.0, 1.0};
        CGColorSpaceRef colorspaceRef = CGColorSpaceCreateDeviceRGB();
        
        UIColor *color1 = [UIColor colorWithRed:0.78 green:0.08 blue:0.09 alpha:1.00];
        UIColor *color2 = [UIColor colorWithRed:0.98 green:0.00 blue:0.03 alpha:1.00];
        
        CGGradientRef gradientRef = CGGradientCreateWithColors(colorspaceRef,
                                                               (CFArrayRef)@[(id)[color1 CGColor], (id)[color2 CGColor]],
                                                               locations);
        CGColorSpaceRelease(colorspaceRef);
        
        CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
                                    gradientRef,
                                    CGPointMake(0, 1),
                                    CGPointMake(CGRectGetMaxX(bounds), 1),
                                    0);
        CGGradientRelease(gradientRef);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        gradientImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, 1, 0)
                                              resizingMode:UIImageResizingModeStretch];
    }
    UIGraphicsEndImageContext();
    return gradientImage;
}

@end
