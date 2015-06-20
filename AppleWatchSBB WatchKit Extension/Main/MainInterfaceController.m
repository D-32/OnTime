//
//  MainInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "MainInterfaceController.h"
#import "Connection.h"
#import "Favourite.h"

@implementation MainInterfaceController {
    NSUserDefaults *_userDefaults;
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
    return segueIdentifier;
}

- (void)willActivate {
    [super willActivate];
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    Connection *connection = (Connection *)[_userDefaults codableObjectForKey:@"pushConnection"];
    if (connection) {
        [_userDefaults removeObjectForKey:@"pushConnection"];
        Favourite *f = [[Favourite alloc] init];
        f.from = connection.from;
        f.to = connection.to;
        [self pushControllerWithName:@"Connections" context:f];
    }
}

- (IBAction)openRss {
    [self pushControllerWithName:@"RSS" context:nil];
//    [self presentControllerWithName:@"RSS" context:nil];
}

@end



