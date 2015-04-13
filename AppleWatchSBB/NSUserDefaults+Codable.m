//
//  NSUserDefaults+Codable.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 13.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "NSUserDefaults+Codable.h"

@implementation NSUserDefaults (Codable)

- (void)setCodableObject:(id<NSCoding>)object forKey:(NSString *)key {
    NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self setObject:encoded forKey:key];
    [self synchronize];
}

- (id<NSCoding>)codableObjectForKey:(NSString *)key {
    NSData* encoded = [self objectForKey:key];
    id<NSCoding> ret = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
    return ret;
}

@end
