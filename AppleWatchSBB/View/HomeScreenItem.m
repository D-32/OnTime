//
//  HomeScreenItem.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 19.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "HomeScreenItem.h"

@implementation HomeScreenItem

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title subtitle:(NSString *)subtitle {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 12;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, frame.size.width - 60, 20)];
        titleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 26, frame.size.width - 60, 20)];
        subtitleLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        subtitleLabel.font = [UIFont systemFontOfSize:12];
        subtitleLabel.text = subtitle;
        [self addSubview:subtitleLabel];
        
        UIImageView *chevron = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chevronThin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        chevron.frame = CGRectMake(frame.size.width - 20, frame.size.height / 2 - 4.5, 5, 9);
        chevron.tintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        [self addSubview:chevron];
    }
    return self;
}

@end
