//
//  RssDetailController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 21.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "RssDetailController.h"
#import <MediaRSSParser/MediaRSSParser.h>

@implementation RssDetailController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    RSSItem *item = context;
    NSString *desc = [[item.itemDescription stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"]; // << regex? :P
    [self.descLabel setText:desc];
}

@end
