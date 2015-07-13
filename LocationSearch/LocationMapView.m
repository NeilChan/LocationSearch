//
//  LocationMapView.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/13.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "LocationMapView.h"

@interface LocationMapView ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *_locationManager;
}
@end

@implementation LocationMapView

- (id)initWithLocation:(CLLocation *)location {
    self = [super init];
    
    if (self) {
        [self mapLocateToLocation:location];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addMap];
   // [self setLocationManager];
}
/**
 *  @author Chan
 *
 *  @brief  设置地图，加入界面中
 */
- (void)addMap {
    _mapView = [[MKMapView alloc]initWithFrame:[self.view bounds]];
    
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
}

/**
 *  @author Chan
 *
 *  @brief  设置定位管理器，检测设备定位功能是否可用
 *
 *  @return void
 */
- (void)setLocationManager {
    _locationManager = [[CLLocationManager alloc]init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *warner = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"提示", @"Remind")]
                                                        message:[NSString stringWithFormat:@"%@",NSLocalizedString(@"定位服务尚未打开，请到设置->隐私->定位中打开", @"Location Services haven't open. Please open it by these steps:Setting->Privacy->Location Services")]
                                                       delegate:self
                                              cancelButtonTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"确定", @"OK")]
                                              otherButtonTitles:nil,nil];
        [warner show];
        return;
    }
    
    //
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        _locationManager.delegate = self;
        
        //设置定位精度与频率
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 1.0;
        
        //iOS8以及以上需要添加,在statUpdatingLocation之前
        //iOS7以及以下是不需要的
        if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
    
}

- (void)mapLocateToLocation:(CLLocation *)location {
    
    float zoomLevel = 0.02;
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    NSLog(@"%@",location);
}

#pragma mark - MKMapViewDelegate

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocationCoordinate2D loc = [userLocation coordinate];
    NSLog(@"%lf  %lf",loc.latitude, loc.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [_mapView setRegion:region animated:YES];
}

/*
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations firstObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    [_locationManager stopUpdatingLocation];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000);
    MKCoordinateRegion adjustRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustRegion];
    
    [manager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
}

*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
