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
@property (nonatomic, assign)NSInteger  radius;
@property (nonatomic, assign)AMapSearchType poiSearchType;

@property (nonatomic, copy)NSString *apiKey;

@end
