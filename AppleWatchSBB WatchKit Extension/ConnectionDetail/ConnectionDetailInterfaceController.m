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

@implementation ConnectionDetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSArray *sections = [context objectForKey:@"sections"];
    
    [self.table setNumberOfRows:sections.count withRowType:@"ConnectionDetail"];
    for (int i = 0; i < sections.count; i++) {
    //for (NSInteger i = sections.count - 1; i >= 0; i--) {
        ConnectionDetailRowController *rowController = [self.table rowControllerAtIndex:i];
        NSDictionary *section = [sections objectAtIndex:i];
        
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
    }
}

@end
