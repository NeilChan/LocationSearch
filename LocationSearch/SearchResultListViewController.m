//
//  SearchResultListViewController.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "SearchResultListViewController.h"
#import "LocationSearchDisplayController.h"
#import "LocationMapView.h"

#import "LocationSearchBar.h"

#import "KVNProgress.h"
#import "AFHTTPRequestOperationManager.h"


#define SEARCH_GOOGLE @"https://maps.googleapis.com/maps/api/place/search/json?location=31.000038,118.750719&radius=1000&types=%@&sensor=true&key=AIzaSyALaqx0MfPsp2aldbZbzEQAq64SwgQfZ0c"

@interface SearchResultListViewController ()<CLLocationManagerDelegate>
{
    //附近所有地点的数组
    NSArray *_locationArr;
    
    //按名称过滤后数组
    NSArray *_filterArr;
    
    LocationSearchDisplayController *_locationSearchDisplayController;
    
    //根据逆地址编码得到地址数据
    CLGeocoder *_geocoder;
    
    //定位管理
    CLLocationManager *_locationManager;
}
@end

@implementation SearchResultListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LocationSearchBar *searchBar = [[LocationSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = [NSString stringWithFormat:@"%@",NSLocalizedString(@"搜索", @"search")];
    
    //设置为tableView的HeaderView
    self.tableView.tableHeaderView = searchBar;
    
    //关联searchbar与searchDisplayController
    _locationSearchDisplayController = [[LocationSearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    
    //关联searchDisplayController与tableviewController的数据源与委托
    _locationSearchDisplayController.searchResultsDataSource = self;
    _locationSearchDisplayController.searchResultsDelegate = self;
    
    
    //进行定位
    [self setLocationManager];
    
    //
    _geocoder = [[CLGeocoder alloc]init];
    
    [self getAddressByLocation:[[CLLocation alloc]initWithLatitude:23.13394716 longitude:113.35326433]];
    [self getCoordinateByAddress:@"广州市安普瑞达汽车维修服务中心"];
    
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
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        _locationManager.delegate = self;
        
        //设置定位精度与频率
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 1.0;
        
        if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
    
}

- (void)getData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [[AFJSONResponseSerializer alloc]init];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    [manager POST:@"http://www.baidu.com"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSPredicate *perdicate = [NSPredicate predicateWithFormat:@"%@",_locationSearchDisplayController.searchBar.text];
    
    //_filterArr = [[NSArray alloc]initWithArray:[_locationArr filteredArrayUsingPredicate:perdicate]];
    return  _locationArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"locationSearchResult";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (tableView == self.tableView) {
        cell.textLabel.text = _locationArr[indexPath.row];
    }else {
        cell.textLabel.text = @"";
    }
    
    return cell;
}


#pragma mark - CoreLocationDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations firstObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    [_locationManager stopUpdatingLocation];
}

#pragma mark - 

/**
 *  @author Chan
 *
 *  @brief  根据定位获得的经纬度进行反地理编码获得地名
 *
 *  @param location 经纬度
 *
 *  @return 地名
 */
- (void)getAddressByLocation:(CLLocation *)location {
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        [self getPlacemark:placemarks[0]];
                        if (placemarks.count == 0)
                            [KVNProgress showErrorWithStatus:[NSString stringWithFormat:@"%@",NSLocalizedString(@"无法定位到所在地点", @"I don't know where are you")]];
                    }];
    LocationMapView *map = [[LocationMapView alloc]initWithLocation:location];
    [self.navigationController pushViewController:map animated:YES];
}

- (void) getPlacemark:(CLPlacemark *)placemark {
    [self getCoordinateByAddress:placemark.name];
}

- (void)getCoordinateByAddress:(NSString *)address {
    [_geocoder geocodeAddressString:address
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                      for (CLPlacemark *placemark in placemarks) {
                          if (placemarks.count ==  0) {
                              NSLog(@"fuck");
                          }
                          NSLog(@"%@",placemark.addressDictionary);
                          NSLog(@"%@  %@  %@  %@",placemark.thoroughfare, placemark.subAdministrativeArea,placemark.subThoroughfare,placemark.postalCode);
                      }
                  }];
    
    
}

@end
