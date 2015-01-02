//
//  ViewController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 01/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@end

@implementation ViewController {
    CLLocationManager* _locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // this is just to get the permission here in the app
    // has to be an instance var, otherwise it will get released, an the alert view disappears
    // a reason to <3 apple
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
