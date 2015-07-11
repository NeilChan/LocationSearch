//
//  Place.h
//  MyBaby
//
//  Created by hu on 15/6/16.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


//地点类别: 0-－其他  1—居住  2-－医院 3-－社区卫生服务中心  4-－幼儿园  5-－小学
typedef enum {
    PlaceType_Other,
    PlaceType_Family,
    PlaceType_Hospital,
    PlaceType_Healthcenter,
    PlaceType_Kindergarten,
    PlaceType_Primaryschool
} PlaceType;


@interface Place : NSObject<NSCoding>

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *place_name;
@property (nonatomic, strong) NSString *place_name_has_X;
@property (nonatomic) PlaceType type;

+ (NSArray *)createByArray:(NSArray *)arr;
+ (Place *)createByDictionary:(NSDictionary *)dic;

- (NSDictionary *)getDictionary;
@end
