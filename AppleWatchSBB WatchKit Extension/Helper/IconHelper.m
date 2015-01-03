//
//  IconHelper.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 03/01/15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "IconHelper.h"

@implementation IconHelper

+ (NSString *)imageNameForCode:(NSInteger)code {
    if (code == 1 || code == 2 || code == 3 || code == 5 || code == 8) {
        return @"train";
    } else if (code == 6) {
        return @"bus";
    } else if (code == 9) {
        return @"tram";
    } else if (code == 4) {
        return @"ship";
    } else if (code == 7) {
        return @"cable";
    }
    NSAssert(NO, @"unknown code");
    return nil;
}

@end
