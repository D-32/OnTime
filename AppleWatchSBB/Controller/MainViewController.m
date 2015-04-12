//
//  MainViewController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 08.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "MainViewController.h"
#import "AppleWatchSBB-Swift.h"
#import "Station.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController () <AutocompleteTextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@end

@implementation MainViewController {
    CLLocationManager* _locationManager;
    UIImageView* _bgImageView;
    UIImageView* _bgBlurImageView;
    AutocompleteTextfield *_inputField;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray* _stations;
    UIView *_container;
    NSUserDefaults *_userDefaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // this is just to get the permission here in the app
    // has to be an instance var, otherwise it will get released, an the alert view disappears
    // a reason to <3 apple
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    NSString *stationId = [_userDefaults stringForKey:@"stationId"];
    NSString *stationName = [_userDefaults stringForKey:@"stationName"];
    
    _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    _bgImageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_bgImageView];
    
    _bgBlurImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-blur"]];
    _bgBlurImageView.contentMode = UIViewContentModeCenter;
    _bgBlurImageView.alpha = 0.0;
    [self.view addSubview:_bgBlurImageView];
    
    _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self.view addSubview:_container];
    
    UIImageView *house = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"house"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    house.tintColor = [UIColor whiteColor];
    [house setFrame:CGRectMake(25, 10, 32, 32)];
    [_container addSubview:house];
    
    UILabel *homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 18, 200, 30)];
    homeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    homeLabel.text = l10n(@"Home Station");
    homeLabel.textColor = [UIColor whiteColor];
    [_container addSubview:homeLabel];
    
    
    _inputField = [[AutocompleteTextfield alloc] initWithFrame:CGRectMake(25, 100, self.view.frame.size.width - 50, 30)];
    _inputField.autoCompleteDelegate = self;
    _inputField.autoCompleteTextColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _inputField.backgroundColor = [UIColor whiteColor];
    _inputField.layer.cornerRadius = 4;
    _inputField.placeholder = l10n(@"Search for a station...");
    _inputField.autoCompleteCellHeight = 44.0;
    _inputField.maximumAutoCompleteCount = 10;
    _inputField.autoCompleteTableHeight = 200;
    _inputField.hideWhenSelected = YES;
    _inputField.enableAttributedText = YES;
    _inputField.returnKeyType = UIReturnKeySearch;
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 0)];
    [_inputField setLeftViewMode:UITextFieldViewModeAlways];
    [_inputField setLeftView:spacerView];
    [self.view addSubview:_inputField];
    [_inputField setupTextField]; // << has to be done after adding it as a subview
    [_inputField setupTableView];
    _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if (stationId) {
        _inputField.text = stationName;
    } else {
        [_inputField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0];
    }
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView animateWithDuration:1.5 animations:^{
        _bgBlurImageView.alpha = 1.0;
    }];
    
    
    CGRect inputFieldframe = _inputField.frame;
    inputFieldframe.origin.y = -30;
    [_inputField setFrame:inputFieldframe];
    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
        CGRect inputFieldframe = _inputField.frame;
        inputFieldframe.origin.y = 100;
        [_inputField setFrame:inputFieldframe];
    } completion:^(BOOL finished) {
    }];
    
    CGRect containerframe = _container.frame;
    containerframe.origin.y = -90;
    [_container setFrame:containerframe];
    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
        CGRect containerframe = _container.frame;
        containerframe.origin.y = 40;
        [_container setFrame:containerframe];
    } completion:^(BOOL finished) {
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - AutocompleteTextFieldDelegate
- (void)didSelectAutocompleteText:(NSString *)text indexPath:(NSIndexPath *)indexPath {
    Station *station = _stations[indexPath.row];
    [_inputField resignFirstResponder];
    [_userDefaults setObject:station.identifier forKey:@"stationId"];
    [_userDefaults setObject:station.title forKey:@"stationName"];
    [_userDefaults synchronize];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.showAnimationType = SlideInToCenter;
    [alert showCustom:self image:[UIImage imageNamed:@"watch"] color:[UIColor colorWithRed:0.46 green:0.71 blue:0.19 alpha:1.00] title:l10n(@"Success") subTitle:@"Now open SBB Watch on your Apple Watch and travel safely." closeButtonTitle:@"Got It" duration:0];
}

- (void)autoCompleteTextFieldDidChange:(NSString *)text {
    [_connection cancel];
    NSURL *URL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://transport.opendata.ch/v1/locations?query=%@&type=station", text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSMutableArray *results = [NSMutableArray array];
    _stations = [NSMutableArray array];
    for (NSDictionary *station in json[@"stations"]) {
        Station* s = [[Station alloc] init];
        s.title = station[@"name"];
        s.identifier = station[@"id"];
        [results addObject:s.title];
        [_stations addObject:s];
    }
    _inputField.autoCompleteStrings = results;
}

@end
