//
//  FavouriteListViewController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 20.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "FavouriteListViewController.h"
#import "Favourite.h"
#import "Station.h"
#import "FavouriteViewController.h"

@implementation FavouriteListViewController {
    NSUserDefaults *_userDefaults;
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
        
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewFav:)];
        self.navigationItem.rightBarButtonItem = addItem;
        
        self.title = l10n(@"Favourites");
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)createNewFav:(id)sender {
    FavouriteViewController *vc = [[FavouriteViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)[_userDefaults codableObjectForKey:@"favs"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    Favourite *fav = [_userDefaults codableObjectForKey:@"favs"][indexPath.row];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, self.tableView.frame.size.width, 50)];
    label.text = [NSString stringWithFormat:@"%@ - %@", fav.from.title, fav.to.title];
    label.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [cell.contentView addSubview:label];
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
