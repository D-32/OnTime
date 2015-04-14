//
//  FavouritesInterfaceController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 14.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "FavouritesInterfaceController.h"
#import "FavouritesRowController.h"
#import "Favourite.h"
#import "Station.h"

@interface FavouritesInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@end

@implementation FavouritesInterfaceController {
    NSArray *_favs;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    _favs = (NSArray *)[userDefaults codableObjectForKey:@"favs"];
    [self.table setNumberOfRows:_favs.count withRowType:@"Favourite"];
    for (int i = 0; i < _favs.count; i++) {
        Favourite *fav = _favs[i];
        FavouritesRowController *rowController = [self.table rowControllerAtIndex:i];
        rowController.toLabel.text = fav.to.title;
        rowController.fromLabel.text = fav.from.title;
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    Favourite *fav = _favs[rowIndex];
    [self pushControllerWithName:@"Connections" context:fav];
}

@end
