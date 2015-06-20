//
//  Connection.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 20.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "Connection.h"

@implementation Connection

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.from = [aDecoder decodeObjectForKey:@"from"];
        self.to = [aDecoder decodeObjectForKey:@"to"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.from forKey:@"from"];
    [aCoder encodeObject:self.to forKey:@"to"];
}

@end
