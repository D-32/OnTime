//
//  ConnectionDetailRowController.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface ConnectionDetailRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceImage *icon;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *trackLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *arrivalNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *arrivalTimeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *departureNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *departureTimeLabel;

@end
