//
//  ConnectionsInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "ConnectionsInterfaceController.h"
#import "ConnectionsRowController.h"
#import "Favourite.h"
#import "Station.h"

@interface ConnectionsInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end

@implementation ConnectionsInterfaceController {
    NSArray *_connections;
    NSDictionary *_station;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSString *fromId;
    NSString *toId;
    if ([context isKindOfClass:[Favourite class]]) {
        Favourite *fav = context;
        fromId = fav.from.identifier;
        toId = fav.to.identifier;
    } else {
        _station = context;
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
        fromId = _station[@"id"];
        toId = [userDefaults objectForKey:@"stationId"];
    }
    
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

- (IBAction)menuMap {
    if (_station) {
        NSDictionary *coordinate = [_station objectForKey:@"coordinate"];
        CLLocationDegrees latitude = [coordinate[@"x"] doubleValue];
        CLLocationDegrees longitude = [coordinate[@"y"] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self presentControllerWithName:@"Map" context:location];
    }
}


@end
