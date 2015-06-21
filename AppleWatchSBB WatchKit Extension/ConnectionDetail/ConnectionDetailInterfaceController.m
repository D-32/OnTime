//
//  ConnectionDetailInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "ConnectionDetailInterfaceController.h"
#import "ConnectionDetailRowController.h"
#import "IconHelper.h"

@interface ConnectionDetailInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@end

@implementation ConnectionDetailInterfaceController {
    NSMutableArray *_notifications;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSArray *sections = context[@"sections"];
    _notifications = [NSMutableArray array];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    BOOL showInfo = ![userDefaults boolForKey:@"notifyFound"];
    
    NSMutableArray *rowTypes = [NSMutableArray array];
    if (showInfo) {
        [rowTypes addObject:@"ConnectionFT"];
    }
    for (int i = 0; i < sections.count; i++) {
        [rowTypes addObject:@"ConnectionDetail"];
    }
    [self.table setRowTypes:rowTypes];
    
    NSString *prev;
    for (int i = 0; i < sections.count; i++) {
        int index = showInfo ? i+1 : i;
        ConnectionDetailRowController *rowController = [self.table rowControllerAtIndex:index];
        NSDictionary *section = sections[i];
        
        NSDictionary *journey = section[@"journey"];
        NSDictionary *walk = section[@"walk"];
        if (![journey isKindOfClass:[NSNull class]]) {
            rowController.nameLabel.text = journey[@"name"];
            NSInteger categoryCode = [journey[@"categoryCode"] integerValue];
            [rowController.icon setImageNamed:[IconHelper imageNameForCode:categoryCode]];
        } else if (![walk isKindOfClass:[NSNull class]]) {
            NSString *duration = walk[@"duration"];
            NSRange range = {3, 2};
            NSInteger minutes = [[duration substringWithRange:range] integerValue];
            rowController.nameLabel.text = [[NSString alloc] initWithFormat:@"%li Minutes", (long)minutes];
            [rowController.icon setImageNamed:@"walk"];
        }
        
        rowController.trackLabel.text = section[@"departure"][@"platform"];
        
        rowController.departureNameLabel.text = section[@"departure"][@"station"][@"name"];
        rowController.arrivalNameLabel.text = section[@"arrival"][@"station"][@"name"];
        
        NSRange range = {11, 5};
        rowController.departureTimeLabel.text = [section[@"departure"][@"departure"] substringWithRange:range];
        rowController.arrivalTimeLabel.text = [section[@"arrival"][@"arrival"] substringWithRange:range];
        
        if (![journey isKindOfClass:[NSNull class]]) {
            if (prev) {
                NSString *message = [NSString stringWithFormat:@"Time to get off! Your next connection is '%@' and leaves at %@", journey[@"name"], section[@"departure"][@"departure"]];
                [_notifications addObject:@{@"time":prev, @"message":message}];
            }
            prev = section[@"arrival"][@"arrival"];
        }
    }
    if (prev) {
        [_notifications addObject:@{@"time":prev, @"message":@"You have reached your destination."}];
    }
}

- (IBAction)registerNotification {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    
    if ([userDefaults boolForKey:@"premium"]) {
        [userDefaults setBool:YES forKey:@"notifyFound"];
        [WKInterfaceController openParentApplication:@{@"type":@"addNotifications", @"notifications":_notifications} reply:nil];
    } else {
        [self presentControllerWithName:@"Premium" context:nil];
    }
}

- (IBAction)clearNotification {
    [WKInterfaceController openParentApplication:@{@"type":@"clearNotifications"} reply:nil];
}

@end
