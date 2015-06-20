//
//  PushViewController.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 20.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Connection;

// TODO: this class is basically the same as FavouriteViewController, we should combine them sometime in the future

@interface PushViewController : UIViewController

- (instancetype)initWithConnection:(Connection *)connection;

@end
