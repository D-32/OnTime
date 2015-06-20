//
//  FavouriteViewController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 12.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "FavouriteViewController.h"
#import "AppleWatchSBB-Swift.h"
#import "Station.h"
#import "Favourite.h"

@interface FavouriteViewController () <AutocompleteTextFieldDelegate>
@end

@implementation FavouriteViewController {
    AutocompleteTextfield *_inputField;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray* _stations;
    Favourite *_favourite;
}

- (instancetype)init {
    return [self initWithFavourite:nil];
}

- (id)initWithFavourite:(Favourite *)favourite {
    if (self = [super init]) {
        _favourite = favourite;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (_favourite) {
        self.title = l10n(@"To");
    } else {
        self.title = l10n(@"From");
    }
    
    _inputField = [[AutocompleteTextfield alloc] initWithFrame:CGRectMake(25, 20, self.view.frame.size.width - 50, 30)];
    _inputField.autoCompleteDelegate = self;
    _inputField.autoCompleteTextColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    _inputField.autoCompleteAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.1 alpha:1.0], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]};
    _inputField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _inputField.layer.cornerRadius = 4;
    _inputField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    _inputField.layer.borderWidth = 0.5;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_inputField becomeFirstResponder];
}

#pragma mark - AutocompleteTextFieldDelegate
- (void)didSelectAutocompleteText:(NSString *)text indexPath:(NSIndexPath *)indexPath {
    Station *station = _stations[indexPath.row];
    if (_favourite) {
        _favourite.to = station;
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
        NSArray *favs = (NSArray *)[userDefaults codableObjectForKey:@"favs"];
        if (!favs) {
            favs = [NSArray array];
        }
        favs = [favs arrayByAddingObject:_favourite];
        [userDefaults setCodableObject:favs forKey:@"favs"];
        [userDefaults synchronize];
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    } else {
        _favourite = [[Favourite alloc] init];
        _favourite.from = station;
        FavouriteViewController *vc = [[FavouriteViewController alloc] initWithFavourite:_favourite];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)autoCompleteTextFieldDidChange:(NSString *)text {
    [self fetchStations];
}

- (void)autoCompleteTextStartEditing {
    
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
