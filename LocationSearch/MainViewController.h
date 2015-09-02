//
//  ViewController.h
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewBaseController, POIViewController;

@interface MainViewController : UIViewController

@property (nonatomic, strong)MapViewBaseController *mapVC;

@property (nonatomic, strong)POIViewController *poiVC;

@end

