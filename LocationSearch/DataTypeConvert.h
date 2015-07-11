//
//  UIViewController+CommonOperation.h
//  MyBaby
//
//  Created by 我的宝宝 on 15/5/29.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataTypeConvert : NSObject 

+(NSDate *) DateWithString : (NSString *)str;
+(NSInteger) IntegerWithString : (NSString *)str;
+(CGFloat) CGFlatWithInterger : (NSInteger *)value;
+(CGFloat) CGFlatWithString : (NSString *)str;
+(CGFloat) CGFlatWithNSNumber : (NSNumber *)number;
+(double)   doubleWithNSNumber : (NSNumber *)number;
+(NSNumber *) NSNumberWithDouble : (double) value;
+(NSNumber *) NumberIntegerWithString : (NSString *)str;


+(NSNumber *) NSNumberWithLong : (long) value;
+(NSNumber *) NumberLongWithString : (NSString *)str;

@end
