//
//  MapInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "MapInterfaceController.h"

@interface MapInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceMap *map;

@end

@implementation MapInterfaceController

- (void)awakeWithContext:(id)context {
    CLLocation *location = context;
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 400, 400)];
    [self.map addAnnotation:location.coordinate withPinColor:WKInterfaceMapPinColorRed];
}

@end
