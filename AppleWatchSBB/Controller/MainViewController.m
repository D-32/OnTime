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

@interface MainViewController () <AutocompleteTextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate>
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
    UIView *_favContainer;
    BOOL _initial;
    UITableView *_favTableView;
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
    
    
    
    
    _favContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height - 170)];
    _favContainer.alpha = 0.0;
    [self.view addSubview:_favContainer];
    
    UIImageView *star = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"star"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    star.tintColor = [UIColor whiteColor];
    [star setFrame:CGRectMake(25, 10, 32, 32)];
    [_favContainer addSubview:star];
    
    UILabel *starLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 18, 200, 30)];
    starLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    starLabel.text = l10n(@"Favourites");
    starLabel.textColor = [UIColor whiteColor];
    [_favContainer addSubview:starLabel];
    
    _favTableView = [[UITableView alloc] initWithFrame:CGRectMake(25, 60, self.view.frame.size.width - 50, _favContainer.frame.size.height - 60)];
    _favTableView.backgroundColor = [UIColor clearColor];
    _favTableView.dataSource = self;
    _favTableView.delegate = self;
    _favTableView.tableFooterView = [[UIView alloc] init];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _favTableView.frame.size.width, 45)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, _favTableView.frame.size.width, 45)];
    label.text = l10n(@"Create new favourite");
    label.textColor = [UIColor whiteColor];
    [header addSubview:label];
    UIImageView *plus = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, 20, 20)];
    plus.image = [UIImage imageNamed:@"plus"];
    [header addSubview:plus];
    [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNewFav:)]];
    _favTableView.tableHeaderView = header;
    
    [_favContainer addSubview:_favTableView];
    
    
    if (stationId) {
        _inputField.text = stationName;
    } else {
        [_inputField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0];
        _favContainer.hidden = YES;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (_initial) {
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
        
        if (!_favContainer.hidden) {
            [UIView animateWithDuration:0.3 delay:1.3 options:0 animations:^{
                _favContainer.alpha = 1.0;
            } completion:^(BOOL finished) {
            }];
        }
        _initial = NO;
    }
    
    [_favTableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)createNewFav:(id)sender {
    FavouriteViewController *vc = [[FavouriteViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)[_userDefaults codableObjectForKey:@"favs"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    Favourite *fav = [_userDefaults codableObjectForKey:@"favs"][indexPath.row];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, _favTableView.frame.size.width, 50)];
    label.text = [NSString stringWithFormat:@"%@ - %@", fav.from.title, fav.to.title];
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    cell.backgroundColor = [UIColor clearColor];
    cell.separatorInset = UIEdgeInsetsMake(0, 32, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *a = [(NSArray *)[_userDefaults codableObjectForKey:@"favs"] mutableCopy];
        [a removeObjectAtIndex:indexPath.row];
        [_userDefaults setCodableObject:[NSArray arrayWithArray:a] forKey:@"favs"];
        [tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
