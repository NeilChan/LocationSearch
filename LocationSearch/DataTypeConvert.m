//
//  UIViewController+CommonOperation.m
//  MyBaby
//
//  Created by 我的宝宝 on 15/5/29.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import "DataTypeConvert.h"

@implementation DataTypeConvert

+(NSDate *) DateWithString : (NSString *)str{
    if(str == nil) return  nil;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat dateFromString:str];
}

+(NSInteger) IntegerWithString : (NSString *)str{
    return [str integerValue];
}

+(CGFloat) CGFlatWithInterger : (NSInteger *)value{
    NSString *str =  [NSString stringWithFormat:@"%f", value];
    return [DataTypeConvert CGFlatWithString:str];
}

+(CGFloat) CGFlatWithString : (NSString *)str{
    return [str floatValue];
}

+(CGFloat) CGFlatWithNSNumber : (NSNumber *)number{
    if(number == nil)
        return 0.f;
    
    return [number floatValue];
}

+(double) doubleWithNSNumber : (NSNumber *)number{
    if(number == nil)
        return 0;
    
    return [number doubleValue];
}

+(NSNumber *) NSNumberWithDouble : (double) value{
    return [[NSNumber alloc] initWithDouble:value];
}

+(NSNumber *) NumberIntegerWithString : (NSString *)str{
    return [NSNumber numberWithInteger:[DataTypeConvert IntegerWithString:str]];
}

+(NSNumber *) NSNumberWithLong : (long) value{
    return [[NSNumber alloc] initWithLong:value];
}

+(NSNumber *) NumberLongWithString : (NSString *)str{
    return [NSNumber numberWithLong:[DataTypeConvert NSNumberWithLong:str]];
}

@end
