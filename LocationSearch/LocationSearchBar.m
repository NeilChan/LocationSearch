//
//  LocationSearchBar.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "LocationSearchBar.h"

@implementation LocationSearchBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setStyle];
    }
    return self;
}

- (void)setStyle {
    self.barStyle = UIBarStyleDefault;
    self.barTintColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:0.5];
    self.tintColor = [UIColor orangeColor];
}

@end
