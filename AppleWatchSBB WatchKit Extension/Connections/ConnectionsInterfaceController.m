//
//  ConnectionsInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "ConnectionsInterfaceController.h"
#import "ConnectionsRowController.h"

@interface ConnectionsInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end

@implementation ConnectionsInterfaceController {
    NSArray *_connections;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSString *fromId = context;
    NSString *toId = @"008501120";
    [self loadConnectionsFrom:fromId to:toId];
}

- (void)loadConnectionsFrom:(NSString *)from to:(NSString *)to {
    NSString *url = [NSString stringWithFormat:@"http://transport.opendata.ch/v1/connections?from=%@&to=%@", from, to];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response,
                                               NSData* data,
                                               NSError* error) {
                               
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               if (!error &&
                                   httpResponse.statusCode >= 200 &&
                                   httpResponse.statusCode <= 299 && data)
                               {
                                   NSError* jsonError;
                                   NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:0
                                                                                          error:&jsonError];
                                   if (!jsonError) {
                                       _connections = json[@"connections"];
                                       [self updateTable];
                                   }
                               }
                           }];
}

- (void)updateTable {
    [self.table setNumberOfRows:_connections.count withRowType:@"Connection"];
    for (int i = 0; i < _connections.count; i++) {
        ConnectionsRowController *rowController = [self.table rowControllerAtIndex:i];
        NSDictionary *connection = _connections[i];
        NSRange range = {11, 5};
        rowController.arrivalNameLabel.text = connection[@"from"][@"station"][@"name"];
        rowController.arrivalTimeLabel.text = [connection[@"from"][@"departure"] substringWithRange:range];
        rowController.departureNameLabel.text = connection[@"to"][@"station"][@"name"];
        rowController.departureTimeLabel.text = [connection[@"to"][@"arrival"] substringWithRange:range];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    return _connections[rowIndex];
}

@end
