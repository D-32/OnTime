//
//  Favourite.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 12.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Station;

@interface Favourite : NSObject <NSCoding>

@property (nonatomic) Station *from;
@property (nonatomic) Station *to;

@end
