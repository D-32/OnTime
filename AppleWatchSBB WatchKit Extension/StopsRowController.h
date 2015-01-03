//
//  StopsRowController.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface StopsRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *trackLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *arrivalLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *departureLabel;

@end
