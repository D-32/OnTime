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

@interface MainViewController () <AutocompleteTextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@end

@implementation MainViewController {
    UIImageView* _bgImageView;
    UIImageView* _bgBlurImageView;
    AutocompleteTextfield *_inputField;
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray* _stations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    _bgImageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_bgImageView];
    
    _bgBlurImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-blur"]];
    _bgBlurImageView.contentMode = UIViewContentModeCenter;
    _bgBlurImageView.alpha = 0.0;
    [self.view addSubview:_bgBlurImageView];
    
    _inputField = [[AutocompleteTextfield alloc] initWithFrame:CGRectMake(25, 100, self.view.frame.size.width - 50, 30)];
    _inputField.autoCompleteDelegate = self;
    _inputField.autoCompleteTextColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    _inputField.backgroundColor = [UIColor whiteColor];
    _inputField.layer.cornerRadius = 4;
    _inputField.placeholder = @"Search for a station...";
    _inputField.autoCompleteCellHeight = 44.0;
    _inputField.maximumAutoCompleteCount = 10;
    _inputField.autoCompleteTableHeight = 200;
    _inputField.hideWhenSelected = YES;
    _inputField.enableAttributedText = YES;
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 0)];
    [_inputField setLeftViewMode:UITextFieldViewModeAlways];
    [_inputField setLeftView:spacerView];
    [self.view addSubview:_inputField];
    [_inputField setupTextField]; // << has to be done after adding it as a subview
    [_inputField setupTableView];
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView animateWithDuration:1.5 animations:^{
        _bgBlurImageView.alpha = 1.0;
    }];
    
    
    CGRect frame = _inputField.frame;
    frame.origin.y = -30;
    [_inputField setFrame:frame];
    [UIView animateWithDuration:0.5 delay:1.0 options:0 animations:^{
        CGRect frame = _inputField.frame;
        frame.origin.y = 100;
        [_inputField setFrame:frame];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - AutocompleteTextFieldDelegate
- (void)didSelectAutocompleteText:(NSString *)text indexPath:(NSIndexPath *)indexPath {
    Station *station = _stations[indexPath.row];
    NSLog(@"selected: %@", station);
    [_inputField resignFirstResponder];
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
