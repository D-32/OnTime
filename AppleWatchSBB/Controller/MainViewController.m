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
#import "FavouriteViewController.h"
#import "Favourite.h"
#import "HomeScreenItem.h"
#import "PremiumViewController.h"
#import "FavouriteListViewController.h"
#import "PushViewController.h"
#import "RssConfigViewController.h"

@interface MainViewController () <AutocompleteTextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@end

@implementation MainViewController {
    CLLocationManager* _locationManager;
    AutocompleteTextfield *_inputField;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray* _stations;
    UIView *_container;
    NSUserDefaults *_userDefaults;
    UIView *_favContainer;
    BOOL _initial;
    UIView *_premiumContainer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _initial = YES;
    
    // this is just to get the permission here in the app
    // has to be an instance var, otherwise it will get released, an the alert view disappears
    // a reason to <3 apple
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    NSString *stationId = [_userDefaults stringForKey:@"stationId"];
    NSString *stationName = [_userDefaults stringForKey:@"stationName"];
    
    _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
    [self.view addSubview:_container];
    
    UIImageView *house = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"house"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    house.tintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [house setFrame:CGRectMake(25, 10, 32, 32)];
    [_container addSubview:house];
    
    UILabel *homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 18, 200, 30)];
    homeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    homeLabel.text = l10n(@"Home Station");
    homeLabel.textColor = [UIColor grayColor];
    [_container addSubview:homeLabel];
    
    
    _inputField = [[AutocompleteTextfield alloc] initWithFrame:CGRectMake(25, 80, self.view.frame.size.width - 50, 38)];
    _inputField.autoCompleteDelegate = self;
    _inputField.autoCompleteTextColor = [UIColor grayColor];
    _inputField.backgroundColor = [UIColor whiteColor];
    _inputField.layer.cornerRadius = 4;
    _inputField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    _inputField.layer.borderWidth = 1.0f;
    _inputField.placeholder = l10n(@"Search for a station...");
    _inputField.autoCompleteCellHeight = 44.0;
    _inputField.maximumAutoCompleteCount = 10;
    _inputField.autoCompleteTableHeight = 200;
    _inputField.hideWhenSelected = YES;
    _inputField.enableAttributedText = YES;
    _inputField.returnKeyType = UIReturnKeySearch;
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    [_inputField setLeftViewMode:UITextFieldViewModeAlways];
    [_inputField setLeftView:spacerView];
    [self.view addSubview:_inputField];
    [_inputField setupTextField]; // << has to be done after adding it as a subview
    [_inputField setupTableView];
    _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    
    
    
    _favContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height - 170)];
    _favContainer.alpha = 0.0;
    [self.view addSubview:_favContainer];
    
    HomeScreenItem *pushItem = [[HomeScreenItem alloc] initWithFrame:CGRectMake(25, 0, self.view.frame.size.width - 50, 50) title:l10n(@"Push Connection") subtitle:l10n(@"Handoff a connection to your watch.")];
    [pushItem addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionPush)]];
    [_favContainer addSubview:pushItem];
    
    HomeScreenItem *favItem = [[HomeScreenItem alloc] initWithFrame:CGRectMake(25, 70, self.view.frame.size.width - 50, 50) title:l10n(@"Favourites") subtitle:l10n(@"Set up connections for quick access.")];
    [favItem addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionFav)]];
    [_favContainer addSubview:favItem];
    
    HomeScreenItem *rssItem = [[HomeScreenItem alloc] initWithFrame:CGRectMake(25, 140, self.view.frame.size.width - 50, 50) title:l10n(@"Configure RSS Feed") subtitle:l10n(@"Setup rail traffic information feed.")];
    [rssItem addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionRss)]];
    [_favContainer addSubview:rssItem];
    
    
    if (stationId) {
        _inputField.text = stationName;
    } else {
        [_inputField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0];
        _favContainer.hidden = YES;
    }
    
    
    UILabel *premiumLabel = [[UILabel alloc] init];
    premiumLabel.font = [UIFont systemFontOfSize:18];
    premiumLabel.text = l10n(@"Activate Premium");
    premiumLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    CGSize size = [premiumLabel.text sizeWithAttributes:@{NSFontAttributeName:premiumLabel.font}];
    premiumLabel.frame = CGRectMake(16, 65, size.width, size.height);
    
    _premiumContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - ((premiumLabel.frame.size.width + 32) / 2), _favContainer.frame.size.height - 200, premiumLabel.frame.size.width + 32, premiumLabel.frame.size.height + 32 + 45)];
    _premiumContainer.backgroundColor = [UIColor whiteColor];
    [_premiumContainer addSubview:premiumLabel];
    _premiumContainer.layer.cornerRadius = 12;
    _premiumContainer.layer.borderWidth = 1.0f;
    _premiumContainer.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    [_premiumContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPremiumController)]];
    [_favContainer addSubview:_premiumContainer];
    
    UIImageView *premiumBadge = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"premium"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    premiumBadge.frame = CGRectMake(_premiumContainer.frame.size.width / 2 - 24, 10, 48, 48);
    premiumBadge.tintColor = [UIColor colorWithRed:0.78 green:0.08 blue:0.09 alpha:1.00];
    [_premiumContainer addSubview:premiumBadge];
    
    
    self.title = @"SBB Watch";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(showInfo)];
    self.navigationItem.rightBarButtonItem = infoItem;
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    [self defaultsChanged:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)defaultsChanged:(id)sender {
    _premiumContainer.hidden = [_userDefaults boolForKey:@"premium"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_initial) {
        CGRect inputFieldframe = _inputField.frame;
        inputFieldframe.origin.y = -40;
        [_inputField setFrame:inputFieldframe];
        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
            CGRect inputFieldframe = _inputField.frame;
            inputFieldframe.origin.y = 80;
            [_inputField setFrame:inputFieldframe];
        } completion:^(BOOL finished) {
        }];
        
        CGRect containerframe = _container.frame;
        containerframe.origin.y = -140;
        [_container setFrame:containerframe];
        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
            CGRect containerframe = _container.frame;
            containerframe.origin.y = 20;
            [_container setFrame:containerframe];
        } completion:^(BOOL finished) {
        }];
        
        if (!_favContainer.hidden) {
            [UIView animateWithDuration:0.3 delay:0.3 options:0 animations:^{
                _favContainer.alpha = 1.0;
            } completion:^(BOOL finished) {
            }];
        }
        _initial = NO;
    }
}

- (void)showInfo {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.showAnimationType = SlideInToCenter;
    [alert addButton:@"Close" actionBlock:^{
        
    }];
    [alert showCustom:self image:[UIImage imageNamed:@"infoWhite"] color:[UIColor colorWithRed:0.78 green:0.08 blue:0.09 alpha:1.00] title:l10n(@"SBB Watch") subTitle:l10n(@"Created by Dylan Marriott\nEmail: info@d-32.com\nTwitter: @dylan36032\nwww.d-32.com\n\nThanks to Charles Vass for the awesome art work.\n\nAlso special thanks to Opendata.ch for providing such a great API.") closeButtonTitle:nil duration:0];
}

- (void)showPremiumController {
    PremiumViewController *vc = [[PremiumViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)actionFav {
    if ([_userDefaults boolForKey:@"premium"]) {
        FavouriteListViewController *vc = [[FavouriteListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showPremiumController];
    }
}

- (void)actionPush {
    PushViewController *vc = [[PushViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionRss {
    if ([_userDefaults boolForKey:@"premium"]) {
        RssConfigViewController *vc = [[RssConfigViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showPremiumController];
    }
}

#pragma mark - AutocompleteTextFieldDelegate
- (void)didSelectAutocompleteText:(NSString *)text indexPath:(NSIndexPath *)indexPath {
    Station *station = _stations[indexPath.row];
    [_inputField resignFirstResponder];
    [_userDefaults setObject:station.identifier forKey:@"stationId"];
    [_userDefaults setObject:station.title forKey:@"stationName"];
    [_userDefaults synchronize];
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.showAnimationType = SlideInToCenter;
    [alert addButton:@"Got It" actionBlock:^{
        _favContainer.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _favContainer.alpha = 1.0;
        }];
    }];
    [alert showCustom:self image:[UIImage imageNamed:@"watch"] color:[UIColor colorWithRed:0.46 green:0.71 blue:0.19 alpha:1.00] title:l10n(@"Success") subTitle:l10n(@"Now open SBB Watch on your Apple Watch and travel safely.") closeButtonTitle:nil duration:0];
}

- (void)autoCompleteTextFieldDidChange:(NSString *)text {
    [self fetchStations];
}

- (void)autoCompleteTextStartEditing {
    [UIView animateWithDuration:0.5 animations:^{
        _favContainer.alpha = 0.0;
    } completion:^(BOOL finished) {
        _favContainer.hidden = YES;
    }];
    [self fetchStations];
}

- (void)fetchStations {
    [_connection cancel];
    NSURL *URL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://transport.opendata.ch/v1/locations?query=%@&type=station", _inputField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
