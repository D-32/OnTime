//
//  StationsInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 02/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "StationsInterfaceController.h"
#import "StationsRowController.h"
#import <CoreLocation/CoreLocation.h>

@interface StationsInterfaceController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end


@implementation StationsInterfaceController {
    NSString *_context;
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    NSArray *_stations;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    _context = context;

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 100;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
}

- (void)loadStations {
    NSString *url = [NSString stringWithFormat:@"http://transport.opendata.ch/v1/locations?x=%f&y=%f&type=station", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
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
                                       _stations = [json objectForKey:@"stations"];
                                       [self updateTable];
                                   }
                               }
                           }];
}

- (void)updateTable {
    [self.table setNumberOfRows:_stations.count withRowType:@"Station"];
    for (int i = 0; i < _stations.count; i++) {
        StationsRowController *rowController = [self.table rowControllerAtIndex:i];
        NSDictionary *station = [_stations objectAtIndex:i];
        rowController.nameLabel.text = [station objectForKey:@"name"];
        rowController.distanceLabel.text = [NSString stringWithFormat:@"%.0fm", [[station objectForKey:@"distance"] doubleValue]];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    if ([_context isEqualToString:@"nearby"]) {
        [self pushControllerWithName:@"Departures" context:[_stations objectAtIndex:rowIndex]];
    } else if ([_context isEqualToString:@"getmehome"]) {
        [self pushControllerWithName:@"Connections" context:[[_stations objectAtIndex:rowIndex] objectForKey:@"id"]];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _currentLocation = [locations lastObject];
    [self loadStations];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

}

@end



