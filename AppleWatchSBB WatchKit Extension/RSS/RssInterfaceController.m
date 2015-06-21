//
//  RssInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 21.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "RssInterfaceController.h"
#import <MediaRSSParser/MediaRSSParser.h>
#import "RssRowController.h"

@interface RssInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (nonatomic) NSArray *items;
@end

@implementation RssInterfaceController {
    RSSParser *_parser;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    _parser = [[RSSParser alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    [userDefaults setBool:YES forKey:@"rssFound"];
    NSString *feedURLString = [userDefaults stringForKey:@"rssfeed"];
    if (!feedURLString) {
        feedURLString = @"http://fahrplan.sbb.ch/bin//help.exe/dnl?tpl=rss_feed_custom&icons=47&regions=BVI1,BVI2,BVI3,BVI4,BVI5";
    }
    
    [_parser parseRSSFeed:feedURLString
                   parameters:nil
                      success:^(RSSChannel *channel) {
                          weakSelf.items = channel.items;
                          [weakSelf.table setNumberOfRows:weakSelf.items.count withRowType:@"RSSItem"];
                          for (int i = 0; i < weakSelf.items.count; i++) {
                              RSSItem *item = weakSelf.items[i];
                              RssRowController *rowController = [weakSelf.table rowControllerAtIndex:i];
                              [rowController.titleLabel setText:item.title];
                          }
                      }
                      failure:^(NSError *error) {
                          NSLog(@"An error occurred: %@", error);
                      }];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    RSSItem *item = _items[rowIndex];
    [self pushControllerWithName:@"RSSDetail" context:item];
}

@end

