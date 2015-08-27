//
//  AMapApiKey.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/8/27.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "AMapApiKey.h"

@implementation AMapApiKey

+ (NSString *)getAPIKey
{
    NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"API_KEY"];
    
    if (key && ![key isEqualToString:@""]) return API_KEY;
    
    return key;
}

+ (void)setAPIKey:(NSString *)key
{
    if (!key || [key isEqualToString:@""]) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"API_KEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
