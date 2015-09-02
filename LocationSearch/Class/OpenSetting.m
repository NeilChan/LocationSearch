//
//  OpenSetting.m
//  MyBaby
//
//  Created by 我的宝宝 on 15/8/13.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import "OpenSetting.h"

@implementation OpenSetting

+ (void)show {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Remind" message:@"openSetting?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
}

+ (void)openSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"open setting finish");
    if (buttonIndex == 0) {
        [OpenSetting openSetting];
    }
}

@end
