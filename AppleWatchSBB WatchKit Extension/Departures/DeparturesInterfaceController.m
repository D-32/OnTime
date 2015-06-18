//
//  DeparturesInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "DeparturesInterfaceController.h"
#import "DeparturesRowController.h"
#import "IconHelper.h"

@interface DeparturesInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end


@implementation DeparturesInterfaceController {
    NSDictionary *_station;
    NSArray *_departures;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    _station = context;
    [self loadDepartures];
}

- (void)loadDepartures {
    NSMutableString *url = [NSMutableString stringWithFormat:@"http://transport.opendata.ch/v1/stationboard?id=%li&limit=20",[_station[@"id"] integerValue]];
    [url appendString:@"&fields[]=stationboard/name"];
    [url appendString:@"&fields[]=stationboard/stop/departure"];
    [url appendString:@"&fields[]=stationboard/to"];
    [url appendString:@"&fields[]=stationboard/categoryCode"];
    [url appendString:@"&fields[]=stationboard/passList/station/name"];
    [url appendString:@"&fields[]=stationboard/passList/arrival"];
    [url appendString:@"&fields[]=stationboard/passList/departure"];
    [url appendString:@"&fields[]=stationboard/passList/platform"];
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
                                       _departures = json[@"stationboard"];
                                       [self updateTable];
                                   }
                               }
                           }];
}

- (void)updateTable {
    [self.table setNumberOfRows:_departures.count withRowType:@"Departure"];
    for (int i = 0; i < _departures.count; i++) {
        DeparturesRowController *rowController = [self.table rowControllerAtIndex:i];
        NSDictionary *item = _departures[i];
        NSString *name = item[@"name"];
        NSRange range = {11, 5};
        NSString *time = [item [@"stop"][@"departure"] substringWithRange:range];
        NSString *destination = item[@"to"];
        rowController.timeLabel.text = time;
        rowController.nameLabel.text = name;
        rowController.destinationLabel.text = destination;

        NSInteger categoryCode = [item[@"categoryCode"] integerValue];
        [rowController.icon setImageNamed:[IconHelper imageNameForCode:categoryCode]];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    NSDictionary *item = _departures[rowIndex];
    return item[@"passList"];
}

- (IBAction)menuMap {
    NSDictionary *coordinate = [_station objectForKey:@"coordinate"];
    CLLocationDegrees latitude = [coordinate[@"x"] doubleValue];
    CLLocationDegrees longitude = [coordinate[@"y"] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self presentControllerWithName:@"Map" context:location];
}

@end



