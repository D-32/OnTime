//
//  FavouritesRowController.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 14.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface FavouritesRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *fromLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *toLabel;

@end
