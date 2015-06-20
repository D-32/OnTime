//
//  RssConfigViewController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 20.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "RssConfigViewController.h"

@interface RssConfig : NSObject 
- (instancetype)initWithIdentifier:(NSString *)i title:(NSString *)t;
- (void)updateDefaults;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *title;
@property (nonatomic) UISwitch *selection;
@end
@implementation RssConfig
- (instancetype)initWithIdentifier:(NSString *)i title:(NSString *)t {
    if (self = [super init]) {
        self.identifier = i;
        self.title = t;
        self.selection = [[UISwitch alloc] init];
        NSUserDefaults *u = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
        self.selection.on = [u boolForKey:self.identifier];
    }
    return self;
}
- (void)updateDefaults {
    NSUserDefaults *u = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    [u setBool:self.selection.on forKey:self.identifier];
}
@end

@implementation RssConfigViewController {
    NSMutableArray *_regions;
    NSMutableArray *_types;
    NSUserDefaults *_userDefaults;
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
        
        _regions = [NSMutableArray array];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"BVI4" title:@"Zürich"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"BVI2" title:@"Mitte"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"BVI1" title:@"Westschweiz"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"BVI5" title:@"Ostschweiz"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"BVI3" title:@"Gotthard / Tessin"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"CSTRI1" title:@"Deutschland"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"CSTRI4" title:@"Frankreich"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"CSTRI3" title:@"Italien"]];
        [_regions addObject:[[RssConfig alloc] initWithIdentifier:@"CSTRI2" title:@"Österreich"]];
        
        _types = [NSMutableArray array];
        [_types addObject:[[RssConfig alloc] initWithIdentifier:@"TI" title:@"Information"]];
        [_types addObject:[[RssConfig alloc] initWithIdentifier:@"TB" title:@"Baustelle"]];
        [_types addObject:[[RssConfig alloc] initWithIdentifier:@"TS" title:@"Störung"]];
        [_types addObject:[[RssConfig alloc] initWithIdentifier:@"TV" title:@"Verspätung"]];
        
        self.title = @"Configure RSS";
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? _regions.count : _types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    RssConfig *config = indexPath.section == 0 ? _regions[indexPath.row] : _types[indexPath.row];
    cell.textLabel.text = config.title;
    [cell.contentView addSubview:config.selection];
    config.selection.frame = CGRectMake(self.view.frame.size.width - 64, 10, 0, 0);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? l10n(@"Region") : l10n(@"Event Type");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSMutableString *region = [NSMutableString string];
    for (RssConfig *config in _regions) {
        [config updateDefaults];
        if (config.selection.on) {
            [region appendString:config.identifier];
            [region appendString:@","];
        }
    }
    if (region.length == 0) {
        // none selected, force first 5
        for (int i = 0; i < 5; i++) {
            RssConfig *c = _regions[i];
            c.selection.on = YES;
            [c updateDefaults];
            [region appendString:c.identifier];
            [region appendString:@","];
        }
    }
    
    NSInteger type = 32;
    NSInteger i = 1;
    for (RssConfig *config in _types) {
        [config updateDefaults];
        if (config.selection.on) {
            type += i;
        }
        i *= 2;
    }
    if (type == 32) {
        // none selected, force first one
        type = 33;
        RssConfig *c = _types[0];
        c.selection.on = YES;
        [c updateDefaults];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://fahrplan.sbb.ch/bin//help.exe/dnl?tpl=rss_feed_custom&icons=%lu&regions=%@", type, region];
    [_userDefaults setObject:url forKey:@"rssfeed"];
}

@end
