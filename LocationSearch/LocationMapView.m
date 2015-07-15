//
//  LocationMapView.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/13.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "LocationMapView.h"
#import "AFHTTPRequestOperationManager.h"

#define GD_API_GET_FROM_KEYWORD @"http://m.amap.com/?k=高德"
#define TEST_URL @"http://m.amap.com/?q=31.234527,121.287689&name=park"

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
    struct RadiusLocation radius = [self setRadiusLocation:loc];
    NSLog(@"%lf  %lf  %lf  %lf",radius.maxLatitude, radius.maxLongitude, radius.minLatitude, radius.minLongitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [_mapView setRegion:region animated:YES];
    
    CLLocation *newLoc = userLocation.location;
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc]init];
    //http请求头应该添加text/plain。接受类型内容无text/plain
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:TEST_URL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responserObject){

             NSLog(@"%@",responserObject);
         }failure:^(AFHTTPRequestOperation *operation, NSError *error){

         }];
    
    /*
    for (CLLocationDegrees i = radius.minLatitude; i < radius.maxLatitude; i += 0.001) {
        for (CLLocationDegrees j = radius.minLongitude; j < radius.maxLongitude; j += 0.001) {
            NSLog(@"%lf  %lf",i, j);
            newLoc = [[CLLocation alloc]initWithLatitude:i longitude:j];
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:newLoc completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0){
            CLPlacemark *placemark = placemarks[0];
            NSLog(@"-----this in locaitonMapview------%@",placemark.addressDictionary);
            NSLog(@"%@  %@  %@  %@",placemark.thoroughfare, placemark.subAdministrativeArea,placemark.subThoroughfare,placemark.postalCode);
            }
        }];
    }
    }
     */
}

/**
 *  @author Chan
 *
 *  @brief  计算并返回以该经纬度为中心点的1km半径内的最大／最小经纬度
 *
 *  @param loc 需要计算的经纬度
 *
 *  @return 返回一个结构体RadiusLocation：其中包含四个值为所求最大／最小经纬度
 */
- (struct RadiusLocation)setRadiusLocation:(CLLocationCoordinate2D)loc{
    //1代表1km. 相应的n km范围就*n
    CGFloat range = 180 / M_PI * 1/ 6372.797;
    
    CGFloat ingR = range / cos(loc.latitude * M_PI / 180);
    
    CLLocationDegrees maxLat = loc.latitude + range;
    CLLocationDegrees maxLong = loc.longitude + ingR;
    CLLocationDegrees minLat = loc.latitude - range;
    CLLocationDegrees minLong = loc.longitude - ingR;
    
    struct RadiusLocation radiusLocation = {maxLat, maxLong, minLat, minLong};
    
    return radiusLocation;
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
