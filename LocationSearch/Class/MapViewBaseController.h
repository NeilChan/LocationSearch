//
//  MapViewBaseController.h
//  MyBaby
//
//  Created by 我的宝宝 on 15/8/21.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@class MAMapView;
@class MAPointAnnotation;

@interface MapViewBaseController : UIViewController
@property(nonatomic, strong)MAMapView *mapView;
@property(nonatomic, strong)AMapSearchAPI *search;
@property(nonatomic, strong)CLLocation *location;
@property(nonatomic, strong)NSArray *locations;
@property(nonatomic, strong)MAPointAnnotation *annotation;
@property(nonatomic, strong)NSMutableArray *annotations;

- (instancetype)initWithCCLocation:(CLLocation *)location;
- (instancetype)initWithCCLocations:(NSArray *)locations;
- (void)initAnnotation;
- (void)initAnnotations;
@end
