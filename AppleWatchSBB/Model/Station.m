//
//  Station.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 08.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "Station.h"

@implementation Station

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.identifier, self.title];
}

@end
