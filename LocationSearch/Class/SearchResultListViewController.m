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
#import "LocationSearchBar.h"

#import "KVNProgress.h"
#import "AFHTTPRequestOperationManager.h"

//接入高德地图SDK
#import <AMapSearchKit/AMapSearchAPI.h>
#import <MAMapKit/MAMapKit.h>


@interface SearchResultListViewController ()<CLLocationManagerDelegate,UISearchDisplayDelegate,UISearchControllerDelegate,AMapSearchDelegate,MAMapViewDelegate>
{
    
    LocationSearchDisplayController *_locationSearchDisplayController;
    
    //---------------数据存放数组-------------------------
    //附近所有地点的数组
    NSArray *_locationArr;
    //按名称过滤后数组
    NSArray *_filterArr;
    //根据查询条件返回的数组
    NSArray *_searchArr;
    
    //当前定位城市
    NSString *_city;
    //当前定位地点
    CLLocationCoordinate2D _currCoordinate2D;
    
    
    
    //----------------高德地图API---------------
    //初始化搜索对象
    AMapSearchAPI *_searchObj_GD;
    //输入提示请求对象
    AMapInputTipsSearchRequest *_tipRequest;
    //关键字搜索
    AMapPlaceSearchRequest *_poiRequest;
    //高德地图对象-----不需要显示，只提供精确定位功能。系统自带定位坐标系与高德地图定位坐标系有偏移
    MAMapView *_mapView_GD;

    

    //---------------系统自带定位管理, 暂不使用---------------
    //系统自带定位管理
    CLLocationManager *_locationManager;
    //系统地理编码转换
    CLGeocoder *_geocoder;
}
@end

@implementation SearchResultListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        //初始化显示数组
        _filterArr = [[NSArray alloc]init];
        self.isNormalSearch = false;
        self.keyword = nil;
        
        //地图注册APIKey
        self.apiKey = @"f5acc5b718535cfa7b542b06352613c3";
        [MAMapServices sharedServices].apiKey = self.apiKey;
        
        //初始化高德地图搜索对象
        [self initGDSearchAndMapViewObj];
        
    }
    
    return self;
}

- (id)initWithApiKey:(NSString *)apiKey andStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    
    if (self) {
        //初始化显示数组
        _filterArr = [[NSArray alloc]init];
        self.isNormalSearch = false;
        self.keyword = nil;
        
        //地图注册APIKey
        [MAMapServices sharedServices].apiKey = apiKey;
        self.apiKey = apiKey;
        
        //初始化高德地图搜索对象
        [self initGDSearchAndMapViewObj];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSearchDisplayController];
    
    //进行系统自带定位-----暂不使用，作废
    //[self openLocationServices];
    
    
    [KVNProgress show];
}

- (void)initGDSearchAndMapViewObj {
    //_lazy load
    if (_mapView_GD == nil) {
        _mapView_GD = [[MAMapView alloc]init];
        _mapView_GD.delegate = self;
        
        //打开系统定位功能。但回调使用高德地图SDK，与系统坐标系有偏移
        _mapView_GD.showsUserLocation = YES;
    }
    
    //_lazy load
    if (_searchObj_GD == nil) {
        _searchObj_GD = [[AMapSearchAPI alloc]initWithSearchKey:self.apiKey Delegate:self];
        //设置搜索返回语言，可选中／英文
        _searchObj_GD.language = AMapSearchLanguage_zh_CN;
    }
    
}

- (void)setSearchDisplayController {
    
    LocationSearchBar *searchBar = [[LocationSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = [NSString stringWithFormat:@"%@",NSLocalizedString(@"搜索", @"search")];
    
    //设置为tableView的HeaderView
    self.tableView.tableHeaderView = searchBar;
    
    //关联searchbar与searchDisplayController
    _locationSearchDisplayController = [[LocationSearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    
    //关联searchDisplayController与tableviewController的数据源与委托
    _locationSearchDisplayController.searchResultsDataSource = self;
    _locationSearchDisplayController.searchResultsDelegate = self;
    _locationSearchDisplayController.delegate = self;
    
}

/**
 *  @author Chan
 *
 *  @brief  反编码获得地名
 *
 *  @param location 坐标
 */
- (void)getReGeocode:(CLLocationCoordinate2D)location {
    AMapReGeocodeSearchRequest *reGeocodeRequest = [[AMapReGeocodeSearchRequest alloc]init];
    
    reGeocodeRequest.searchType = AMapSearchType_ReGeocode;
    reGeocodeRequest.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    reGeocodeRequest.radius = 10000;
    reGeocodeRequest.requireExtension = YES;
    [_searchObj_GD AMapReGoecodeSearch:reGeocodeRequest];
}

/**
 *  @author Chan
 *
 *  @brief  获得输入提示
 *
 *  @param keyword 输入的关键词
 */
- (void)getInputTips:(NSString *)keyword {
    
    if (!_tipRequest) {
        _tipRequest = [[AMapInputTipsSearchRequest alloc]init];
        _tipRequest.searchType = AMapSearchType_InputTips;
    }
    
    _tipRequest.keywords = keyword;
    _tipRequest.city = @[_city];
    
    [_searchObj_GD AMapInputTipsSearch:_tipRequest];
}


/**
 *  @author Chan
 *
 *  @brief  根据keyword跟地理坐标返回搜索内容
 *
 *  @param keyword      搜索内容
 *  @param coordinate2D 用户坐标
 */
- (void)searchWithKeyword:(NSString *)keyword andLocation:(CLLocationCoordinate2D)coordinate2D {
    
    if ([keyword isEqualToString:@""]){
        [self setIsNormalSearch:true];
        return;
    }
    
    if (!_poiRequest) {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
        _poiRequest.searchType = AMapSearchType_PlaceAround;
    }
    
    if (!coordinate2D.longitude && !coordinate2D.latitude) {NSLog(@"coordinate haven't load.");return;}
    
    _poiRequest.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude
                                                    longitude:coordinate2D.longitude];
    _poiRequest.requireExtension = YES;
    _poiRequest.keywords = keyword;
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
    
}


- (void)searchWithLocation:(CLLocationCoordinate2D)coordinate2D {
    
    if (!_poiRequest) {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
        _poiRequest.searchType = AMapSearchType_PlaceAround;
    }
    
    _poiRequest.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude
                                                    longitude:coordinate2D.longitude];
    _poiRequest.keywords = @"餐饮服务|汽车服务|汽车销售|汽车维修|摩托车服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    _poiRequest.requireExtension = YES;
    _poiRequest.sortrule = 1;
    
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
}

- (void)filterData:(NSString *)searchStr{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", searchStr];
    
    _filterArr = [_locationArr filteredArrayUsingPredicate:predicate];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_locationSearchDisplayController.searchResultsTableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AMapSearchDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    if (response.regeocode) {
        //处理搜索结果
        AMapReGeocode *result = response.regeocode;
        
        if (result.addressComponent.city) {
            _city = result.addressComponent.city;
            
            //停止定位
            _mapView_GD.showsUserLocation = NO;
        }
    }
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {
    
    if (response.tips.count == 0) {
        _filterArr = [[NSArray alloc]init];
        return;
    }
    
    _filterArr = response.tips;
    
    //刷新界面如果放到searchDisplayController里面自动刷新会慢一拍
    dispatch_async(dispatch_get_main_queue(), ^{
        [_locationSearchDisplayController.searchResultsTableView reloadData];
    });
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response {
    NSLog(@"on place done");
    if(response.pois.count == 0)
    {
        return;
    }
    
    _locationArr = response.pois;
    
    
    //刷新界面如果放到searchDisplayController里面自动刷新会慢一拍
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}



#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    
    if (userLocation) {
        NSLog(@"I was in the mapView_GD latitude : %f ,longitude : %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        
        _currCoordinate2D = userLocation.coordinate;
        
        //如果获取到定位经纬度，则反编码获取地名
        [self getReGeocode:userLocation.coordinate];
        
        //
        if (self.isNormalSearch == true) {
            [self searchWithLocation:_currCoordinate2D];
        }
        else if(self.keyword) {
            [self searchWithKeyword:self.keyword andLocation:_currCoordinate2D];
        }
        
        [KVNProgress dismiss];
    }
    else {
        [KVNProgress showErrorWithStatus:[NSString stringWithFormat:@"%@",NSLocalizedString(@"无法定位到所在位置", @"Can't access your location")]];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        return _locationArr.count;
    }
    
    return  _filterArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"locationSearchResult";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (tableView == self.tableView) {
        AMapPOI *poi = _locationArr[indexPath.row];
        cell.textLabel.text = poi.name;
    }else {
        AMapTip *tip = _filterArr[indexPath.row];
        cell.textLabel.text = tip.name;
    }
    
    return cell;
}



#pragma mark - UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    if (_isNormalSearch == false) {
        [self filterData:searchString];
    }else {
        [self getInputTips:searchString];
    }
    
    //不在此刷新，因为数据可能不出来
    return NO;
}





//--------------------------暂不使用系统定位功能，保持坐标数据一致性全部使用高德地图API处理----------------------------------

/**
 *  @author Chan
 *
 *  @brief  设置定位管理器，检测设备定位功能是否可用
 *
 *  @return void
 */
- (void)openLocationServices {
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
        
        //KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
        [KVNProgress showWithStatus:[NSString stringWithFormat:@"%@",NSLocalizedString(@"定位中", @"Locate...")]];
    }
}

#pragma mark - CoreLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations firstObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    //NSLog(@"locates success");
    
    NSLog(@"I was in the systemLocation latitude : %f ,longitude : %f", location.coordinate.latitude, location.coordinate.longitude);
    
    //[_locationManager stopUpdatingLocation];
    
    //获取经纬度成功
    //则进行地理反编码提取所在地点信息
    /*
     if (location) {
     _geocoder = [[CLGeocoder alloc]init];
     [self getAddressByLocation:location];
     [self getReGeocode:coordinate];
     }
     */
    
    [KVNProgress dismiss];
}

#pragma mark - 使用系统功能进行地理反编码处理
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
                        //
                        CLPlacemark *placemark = placemarks[0];
                        NSLog(@"-----this in locaitonMapview------%@",placemark.addressDictionary);
                        NSLog(@"%@  %@  %@  %@",placemark.thoroughfare, placemark.subAdministrativeArea,placemark.subThoroughfare,placemark.postalCode);
                        if (placemarks.count == 0)
                            [KVNProgress showErrorWithStatus:[NSString stringWithFormat:@"%@",NSLocalizedString(@"无法定位到所在地点", @"I don't know where are you")]];
                        else
                            [self getPlacemark:placemarks[0]];
                    }];
}

- (void)getPlacemark:(CLPlacemark *)placemark {
    _city = placemark.addressDictionary[@"City"];
    [self getInputTips:_city];
}

/**
 *  @author Chan
 *
 *  @brief  根据地名获取经纬度信息－－－－暂不需用到
 *
 *  @param address 详细地名：省－区－市－街道
 */
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




//---------------------------暂不进行定位模糊修正，按照高德SDK标准用法使用--------------------------------------------

/**
 *  @author Chan
 *
 *  @brief  根据地名获得坐标
 *
 *  @param address 详细地址
 *  @param city    城市
 */
- (void)getGeocode:(NSString *)address City:(NSString *)city{
    AMapGeocodeSearchRequest *geocodeRequest = [[AMapGeocodeSearchRequest alloc]init];
    
    geocodeRequest.searchType = AMapSearchType_Geocode;
    geocodeRequest.address = address;
    geocodeRequest.city = @[city];
    
    [_searchObj_GD AMapGeocodeSearch:geocodeRequest];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    if (response.geocodes != nil) {
        AMapGeocode *geocode = response.geocodes[0];
        _currCoordinate2D = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
    }
    
    [self searchWithKeyword:@"住宅小区" andLocation:_currCoordinate2D];
}

@end





