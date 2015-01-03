//
//  DeparturesInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "DeparturesInterfaceController.h"
#import "DeparturesRowController.h"

@interface DeparturesInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end


@implementation DeparturesInterfaceController {
    NSDictionary *_station;
    NSArray *_departures;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    _station = (NSDictionary *)context;
    [self loadDepartures];
}

- (void)loadDepartures {
    NSString *url = [NSString stringWithFormat:@"http://transport.opendata.ch/v1/stationboard?id=%li&limit=8", (long)[[_station objectForKey:@"id"] integerValue]];
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
                                       _departures = [json objectForKey:@"stationboard"];
                                       [self updateTable];
                                   }
                               }
                           }];
}

- (void)updateTable {
    [self.table setNumberOfRows:_departures.count withRowType:@"Departure"];
    for (int i = 0; i < _departures.count; i++) {
        DeparturesRowController *rowController = [self.table rowControllerAtIndex:i];
        NSDictionary *item = [_departures objectAtIndex:i];
        NSString *name = [item objectForKey:@"name"];
        NSRange range = {11, 5};
        NSString *time = [[[item objectForKey:@"stop"] objectForKey:@"departure"] substringWithRange:range];
        NSString *destination = [item objectForKey:@"to"];
        rowController.timeLabel.text = time;
        rowController.nameLabel.text = name;
        rowController.destinationLabel.text = destination;

        NSInteger categoryCode = [[item objectForKey:@"categoryCode"] integerValue];
        if (categoryCode == 1 || categoryCode == 2 || categoryCode == 3 || categoryCode == 5 || categoryCode == 8) {
            [rowController.icon setImageNamed:@"train"];
        } else if (categoryCode == 6) {
            [rowController.icon setImageNamed:@"bus"];
        } else if (categoryCode == 9) {
            [rowController.icon setImageNamed:@"tram"];
        } else if (categoryCode == 4) {
            [rowController.icon setImageNamed:@"ship"];
        } else if (categoryCode == 7) {
            [rowController.icon setImageNamed:@"cable"];
        }
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    NSDictionary *item = [_departures objectAtIndex:rowIndex];
    return [item objectForKey:@"passList"];
}

- (IBAction)menuMap {
    NSDictionary *coordinate = [_station objectForKey:@"coordinate"];
    CLLocationDegrees latitude = [[coordinate objectForKey:@"x"] doubleValue];
    CLLocationDegrees longitude = [[coordinate objectForKey:@"y"] doubleValue];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self presentControllerWithName:@"Map" context:location];
}

@end



