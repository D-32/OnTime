//
//  NSUserDefaults+Codable.h
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 13.04.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Codable)

- (void)setCodableObject:(id<NSCoding>)object forKey:(NSString *)key;
- (id<NSCoding>)codableObjectForKey:(NSString *)key;

@end
