//
//  AMapApiKey.h
//  LocationSearch
//
//  Created by 我的宝宝 on 15/8/27.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMapApiKey : NSObject

+ (NSString *)getAPIKey;

+ (void)setAPIKey:(NSString *)key;

@end
