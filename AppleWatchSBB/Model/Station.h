//
//  Station.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 08.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Station : NSObject <NSCoding>

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *title;

@end
