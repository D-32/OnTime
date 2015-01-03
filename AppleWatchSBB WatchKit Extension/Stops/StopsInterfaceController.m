//
//  StopsInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "StopsInterfaceController.h"
#import "StopsRowController.h"

@interface StopsInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end

@implementation StopsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSArray *stops = (NSArray *)context;
    [self.table setNumberOfRows:stops.count withRowType:@"Stop"];
    for (int i = 0; i < stops.count; i++) {
        StopsRowController *rowController = [self.table rowControllerAtIndex:i];
        NSDictionary *stop = [stops objectAtIndex:i];
        rowController.nameLabel.text = [[stop objectForKey:@"station"] objectForKey:@"name"];
        
        NSRange range = {11, 5};
        NSString *arrivalTime = [stop objectForKey:@"arrival"];
        NSString *arrival;
        if (![arrivalTime isKindOfClass:[NSNull class]]) {
            arrival = [arrivalTime substringWithRange:range];
        }
        rowController.arrivalLabel.text = arrival;
        
        NSString *departureTime = [stop objectForKey:@"departure"];
        NSString *departure;
        if (![departureTime isKindOfClass:[NSNull class]]) {
            departure = [departureTime substringWithRange:range];
        }
        rowController.departureLabel.text = departure;
        
        rowController.trackLabel.text = [stop objectForKey:@"platform"];
    }
}

@end
