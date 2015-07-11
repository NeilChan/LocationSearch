//
//  Place.m
//  MyBaby
//
//  Created by hu on 15/6/16.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import "Place.h"
#import "DataTypeConvert.h"

@implementation Place


+ (NSArray *)createByArray:(NSArray *)arr{
    NSMutableArray *retArray=[[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in arr) {
        [retArray addObject:[[self class] createByDictionary:dic]];
    }
    
    return retArray;
}

+ (Place *)createByDictionary:(NSDictionary *)dic{
    Place *place = [[Place alloc] init];
    
    place.ID = [[dic objectForKey:@"post_id"] numberFromString:[dic objectForKey:@"post_id"]];
    
    if([dic objectForKey:@"longitude"]!=nil)
        place.longitude = [DataTypeConvert doubleWithNSNumber:[dic objectForKey:@"longitude"]];
    if([dic objectForKey:@"latitude"]!=nil)
        place.latitude = [DataTypeConvert doubleWithNSNumber:[dic objectForKey:@"latitude"]];
    if([dic objectForKey:@"country"]!=nil)
        place.country = [dic objectForKey:@"country"];
    if([dic objectForKey:@"state"]!=nil)
        place.state = [dic objectForKey:@"state"];
    if([dic objectForKey:@"city"]!=nil)
        place.city = [dic objectForKey:@"city"];
    if([dic objectForKey:@"district"]!=nil)
        place.district = [dic objectForKey:@"district"];
    if([dic objectForKey:@"address"]!=nil)
        place.address = [dic objectForKey:@"address"];
    if([dic objectForKey:@"place_name"]!=nil){
        place.place_name = [dic objectForKey:@"place_name"];
        place.place_name_has_X = [NSString stringWithFormat:@"#%@",place.place_name];
    }
    if([dic objectForKey:@"type"]!=nil)
        place.type = [[dic objectForKey:@"type"] integerValue];
    
    return place;
}


- (NSDictionary *)getDictionary{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    
    if(self.ID!=nil)
        [dic setObject:self.ID forKey:@"post_id"];

    [dic setObject:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    [dic setObject:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    
    if(self.country!=nil)
        [dic setObject:self.country forKey:@"country"];
    if(self.state!=nil)
        [dic setObject:self.state forKey:@"state"];
    if(self.city!=nil)
        [dic setObject:self.city forKey:@"city"];
    if(self.district!=nil)
        [dic setObject:self.district forKey:@"district"];
    if(self.address!=nil)
        [dic setObject:self.address forKey:@"address"];
    if(self.place_name!=nil){
        [dic setObject:self.place_name forKey:@"place_name"];
        self.place_name_has_X = [NSString stringWithFormat:@"#%@",self.place_name];
    }

     [dic setObject:[NSNumber numberWithInteger:self.type] forKey:@"type"];
    
    return dic;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    if(self = [super init]) {
        self.ID=[coder decodeObjectForKey:@"ID"];
        self.longitude = [coder decodeDoubleForKey:@"longitude"];
        self.latitude = [coder decodeDoubleForKey:@"latitude"];
        self.country = [coder decodeObjectForKey:@"country"];
        self.state = [coder decodeObjectForKey:@"state"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.district = [coder decodeObjectForKey:@"district"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.place_name = [coder decodeObjectForKey:@"place_name"];
        self.place_name_has_X = [coder decodeObjectForKey:@"place_name_has_X"];
        self.type = [[coder decodeObjectForKey:@"type"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject: self.ID forKey:@"ID"];
    [coder encodeDouble: self.longitude forKey:@"longitude"];
    [coder encodeDouble: self.latitude forKey:@"latitue"];
    [coder encodeObject: self.country forKey:@"country"];
    [coder encodeObject: self.state forKey:@"state"];
    [coder encodeObject: self.city forKey:@"city"];
    [coder encodeObject: self.district forKey:@"district"];
    [coder encodeObject: self.address forKey:@"address"];
    [coder encodeObject: self.place_name forKey:@"place_name"];
    [coder encodeObject: self.place_name_has_X forKey:@"place_name_has_X"];
    [coder encodeObject: [NSNumber numberWithInteger:self.type] forKey:@"type"];
}


@end
