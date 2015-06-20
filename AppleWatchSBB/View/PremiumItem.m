//
//  PremiumItem.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 20.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "PremiumItem.h"

@implementation PremiumItem

- (instancetype)initWithFrame:(CGRect)frame icon:(UIImage *)icon title:(NSString *)title desc:(NSString *)desc {
    if (self = [super initWithFrame:frame]) {
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        iconView.frame = CGRectMake(25, 25, 32, 32);
        [self addSubview:iconView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 25, self.frame.size.width - 97, 18)];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 45, self.frame.size.width - 97, 40)];
        descLabel.font = [UIFont systemFontOfSize:13];
        descLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        descLabel.numberOfLines = 2;
        descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descLabel.text = desc;
        [self addSubview:descLabel];
    }
    return self;
}

@end
