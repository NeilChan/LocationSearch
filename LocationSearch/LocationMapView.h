//
//  LocationMapView.h
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/13.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationMapView : UIViewController
@property (nonatomic, strong)MKMapView *mapView;
- (id)initWithLocation:(CLLocation *)location;
@end
