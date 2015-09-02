//
//  POIViewController.h
//  LocationSearch
//
//  Created by 我的宝宝 on 15/9/2.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface POIViewController : UITableViewController

@property (nonatomic, strong)NSString   *keyword;
@property (nonatomic, strong)NSArray    *type;
@property (nonatomic, strong)NSString   *currentCity;
@property (nonatomic, assign)CLLocationCoordinate2D currCoordinate2D;
@property (nonatomic, assign)NSInteger  radius;
@property (nonatomic, assign)NSInteger  offset;
@property (nonatomic, assign)AMapSearchType poiSearchType;

@property (nonatomic, strong)AMapSearchAPI *searchObj_GD;;
@property (nonatomic, copy)NSString *apiKey;

@end
