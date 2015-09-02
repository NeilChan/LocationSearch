//
//  POIViewController.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/9/2.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "POIViewController.h"
#import "LocationSearchDisplayController.h"
#import "LocationSearchBar.h"
#import "MapViewBaseController.h"

#import "KVNProgress.h"
#import "MJRefresh.h"
//接入高德地图SDK
#import <MAMapKit/MAMapKit.h>
#import "AMapApiKey.h"

@interface POIViewController ()<CLLocationManagerDelegate,UISearchDisplayDelegate,UISearchControllerDelegate,AMapSearchDelegate,MAMapViewDelegate>
{
    LocationSearchDisplayController *_locationSearchDisplayController;
    
    //--------------Data-------------
    //附近所有地点的数组
    NSMutableArray *_locationArr;
    //按名称过滤后数组
    NSArray *_filterArr;
    //根据查询条件返回的数组
    NSArray *_searchArr;
    //当前返回页数
    NSInteger _currentPage;
    //当前定位城市
    NSString *_currentCity;
    //当前定位地点
    CLLocationCoordinate2D _currCoordinate2D;
    
    
    //--------------Component-----------
    UIActivityIndicatorView *_activityIndicator;
    //系统自带定位管理，检测是否系统定位／本应用定位可用
    CLLocationManager *_locationManager;
    
    
    //--------------GD Framework-------
    //初始化搜索对象
    AMapSearchAPI *_searchObj_GD;
    //输入提示请求对象
    AMapInputTipsSearchRequest *_tipRequest;
    //关键字搜索
    AMapPlaceSearchRequest *_poiRequest;
    //高德地图对象-----不需要显示，只提供精确定位功能。系统自带定位坐标系与高德地图定位坐标系有偏移
    MAMapView *_mapView_GD;
    

}
@end

@implementation POIViewController
#pragma mark - Initalize


- (void)getMoreEvent
{
    [self getMoreData];
}

- (void)getMoreData
{
    _currentPage ++ ;
    [self searchWithLocation:_currCoordinate2D];
}

#pragma mark - Set request and send request

/**
 *  @brief 反编码获得地名
 *  @param location 坐标
 */
- (void)getReGeocode:(CLLocationCoordinate2D)location
{
    AMapReGeocodeSearchRequest *reGeocodeRequest = [[AMapReGeocodeSearchRequest alloc]init];
    
    reGeocodeRequest.searchType = AMapSearchType_ReGeocode;
    reGeocodeRequest.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    reGeocodeRequest.radius = 10000;
    reGeocodeRequest.requireExtension = YES;
    [_searchObj_GD AMapReGoecodeSearch:reGeocodeRequest];
}

/**
 *  @brief  根据地名获得坐标
 *  @param address 详细地址
 *  @param adcode  区域编码
 */
- (void)getGeocode:(NSString *)address adcode:(NSString *)adcode{
    if (address.length == 0) {
        return;
    }
    
    AMapGeocodeSearchRequest *geocodeRequest = [[AMapGeocodeSearchRequest alloc]init];
    
    geocodeRequest.searchType = AMapSearchType_Geocode;
    geocodeRequest.address = address;
    geocodeRequest.city = @[adcode];
    
    [_searchObj_GD AMapGeocodeSearch:geocodeRequest];
}

/**
 *  @brief  获得输入提示
 *  @param keyword 输入的关键词
 */
- (void)getInputTips:(NSString *)keyword
{
    
    if (!_tipRequest) {
        _tipRequest = [[AMapInputTipsSearchRequest alloc]init];
        _tipRequest.searchType = AMapSearchType_InputTips;
    }
    
    _tipRequest.keywords = keyword;
    _tipRequest.city = @[_currentCity];
    
    [_searchObj_GD AMapInputTipsSearch:_tipRequest];
}


/**
 *  @brief  根据keyword跟地理坐标返回搜索内容
 *  @param keyword      搜索内容
 *  @param coordinate2D 用户坐标
 */
- (void)searchWithKeyword:(NSString *)keyword andLocation:(CLLocationCoordinate2D)coordinate2D {
    
    if ([keyword isEqualToString:@""]){
        return;
    }
    
    if (!_poiRequest) {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
        _poiRequest.searchType = AMapSearchType_PlaceKeyword;
    }
    
    if (!coordinate2D.longitude && !coordinate2D.latitude) {NSLog(@"coordinate haven't load.");return;}
    
    _poiRequest.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude
                                                    longitude:coordinate2D.longitude];
    _poiRequest.requireExtension = YES;
    _poiRequest.keywords = keyword;
    _poiRequest.offset = 50;
    _poiRequest.page = _currentPage;
    _poiRequest.requireExtension = YES;
    _poiRequest.sortrule = 1;
    _poiRequest.radius = 10000;
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
    
}


- (void)searchWithLocation:(CLLocationCoordinate2D)coordinate2D {
    
    if (!_poiRequest) {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
        _poiRequest.searchType = AMapSearchType_PlaceAround;
    }
    
    _poiRequest.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude
                                                    longitude:coordinate2D.longitude];
    _poiRequest.types = @[@"餐饮服务",@"汽车销售",@"购物服务",@"生活服务",@"体育休闲服务",@"医疗保健服务",@"住宿服务",@"风景名胜",@"商务住宅",@"科教文化服务",@"公司企业",@"政府机构及社会团体",@"金融保险服务"];
    // _poiRequest.keywords = @"餐饮服务|汽车服务|汽车销售|汽车维修|摩托车服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息";
    _poiRequest.offset           = 50;
    _poiRequest.page             = _currentPage;
    _poiRequest.requireExtension = YES;
    _poiRequest.sortrule         = 1;
    _poiRequest.radius           = 10000;
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
    
}


- (void)filterData:(NSString *)searchStr{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", searchStr];
    
    _filterArr = [[_locationArr copy] filteredArrayUsingPredicate:predicate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_locationSearchDisplayController.searchResultsTableView reloadData];
    });
    
}



#pragma mark - AMapSearchDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if (response.regeocode) {
        //处理搜索结果
        AMapReGeocode *result = response.regeocode;
        
        if (result.addressComponent.city) {
            _currentCity = result.addressComponent.city;
            
            //停止定位
            _mapView_GD.showsUserLocation = NO;
        }
    }
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    
    if(response.geocodes.count == 0){
        return;
    }
    
    AMapGeocode *geocode = response.geocodes[0];
    NSLog(@"%@",geocode);
    _currCoordinate2D = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
    
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    
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

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    NSLog(@"on place done: %@",response.pois);
    
    if(response.pois.count == 0)
    {
        [self.tableView.footer endRefreshing];
        return;
    }
    
    if (!_locationArr || _locationArr.count == 0) {
        _locationArr = [[NSMutableArray alloc]initWithArray:response.pois];
    }else {
        [_locationArr addObjectsFromArray:response.pois];
    }
    
    if (_currentPage == 1) {
        AMapPOI *poi = [self copyAMapPOI:_locationArr[0]];
        poi.name = poi.address;
        
        NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:[_locationArr copy]];
        [tmp insertObject:poi atIndex:0];
        
        poi = [self copyAMapPOI:tmp[0]];
        poi.name = poi.district;
        [tmp insertObject:poi atIndex:0];
        
        poi = [self copyAMapPOI:tmp[0]];
        poi.name = poi.city;
        [tmp insertObject:poi atIndex:0];
        
        _locationArr = [[NSMutableArray alloc]initWithArray:[tmp copy]];
    }
    
    //刷新界面如果放到searchDisplayController里面自动刷新会慢一拍
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView.footer endRefreshing];
    });
}

- (AMapPOI *)copyAMapPOI:(AMapPOI *)poi
{
    AMapPOI *poiCopy = [[AMapPOI alloc]init];
    
    poiCopy.name = [poi.name copy];
    poiCopy.province = [poi.province copy];
    poiCopy.district = [poi.district copy];
    poiCopy.city = [poi.city copy];
    poiCopy.address = [poi.address copy];
    poiCopy.location.latitude = poi.location.latitude;
    poiCopy.location.longitude = poi.location.longitude;
    poiCopy.citycode = poi.citycode;
    
    return poiCopy;
}



#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    if (userLocation) {
        NSLog(@"I was in the mapView_GD latitude : %f ,longitude : %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        //定不到位
        if (userLocation.coordinate.longitude == 0 && userLocation.coordinate.latitude)
        {
            return;
        }
        
        _currCoordinate2D = userLocation.coordinate;
        
        //如果获取到定位经纬度，则反编码获取地名
        [self getReGeocode:userLocation.coordinate];
        
#warning isNormalSearch
//        if (self.isNormalSearch == true) {
//            [self searchWithLocation:_currCoordinate2D];
//        }
//        else if(self.keyword) {
//            [self searchWithKeyword:self.keyword andLocation:_currCoordinate2D];
//        }
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _locationSearchDisplayController.searchResultsTableView) {
        AMapTip *tip = _filterArr[indexPath.row];
        [self getGeocode:tip.district adcode:tip.adcode];
    }else if(tableView == self.tableView) {
        AMapPOI *poi = _locationArr[indexPath.row];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:poi.location.latitude longitude:poi.location.longitude];
        MapViewBaseController *mapVC = [[MapViewBaseController alloc]initWithCCLocation:location];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _locationArr.count - 10) {
        [self getMoreEvent];
    }
}



#pragma mark - UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
#warning isNormalesearch
//    if (_isNormalSearch == false) {
//        [self filterData:searchString];
//    }else {
//        [self getInputTips:searchString];
//    }
    
    //不在此刷新，因为数据会慢一步出来
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
    
    NSLog(@"I was in the systemLocation latitude : %f ,longitude : %f", location.coordinate.latitude, location.coordinate.longitude);
}

#pragma mark - Life Cycle Of View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSearchDisplayController];
    [self initRefreshControl];
    
    //进行系统自带定位-----暂不使用，作废
    //[self openLocationServices];
    
    [KVNProgress show];
}

#pragma mark - Initialize or Dealloc

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self initClassData];
        
        self.apiKey = [AMapApiKey getAPIKey];
        
        [MAMapServices sharedServices].apiKey = self.apiKey;
        
        [self initGDSearchAndMapViewObj];
    }
    
    return self;
}

- (id)initWithApiKey:(NSString *)apiKey andStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self initClassData];
        
        [MAMapServices sharedServices].apiKey = apiKey;
        
        self.apiKey = apiKey;
        
        [AMapApiKey setAPIKey:apiKey];
        
        [self initGDSearchAndMapViewObj];
    }
    
    return self;
}

- (void)initClassData
{
    _filterArr          = [[NSArray alloc]init];
    _currentPage        = 1;
    self.keyword        = nil;
    self.type           = nil;
    self.radius         = 3000;
    self.poiSearchType  = AMapSearchType_PlaceAround;
}

- (void)initGDSearchAndMapViewObj
{
    //_lazy load
    if (_mapView_GD == nil)
    {
        _mapView_GD                     = [[MAMapView alloc]init];
        _mapView_GD.delegate            = self;
        _mapView_GD.showsUserLocation   = YES;
    }
    
    //_lazy load
    if (_searchObj_GD == nil)
    {
        _searchObj_GD           = [[AMapSearchAPI alloc]initWithSearchKey:self.apiKey Delegate:self];
        _searchObj_GD.language  = AMapSearchLanguage_zh_CN;
    }
}

- (void)initSearchDisplayController
{
    
    LocationSearchBar *searchBar    = [[LocationSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder           = [NSString stringWithFormat:@"%@",NSLocalizedString(@"POI搜索", @"search")];
    
    //设置为tableView的HeaderView
    self.tableView.tableHeaderView      = searchBar;
    
    //关联searchbar与searchDisplayController
    _locationSearchDisplayController    = [[LocationSearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    
    //关联searchDisplayController与tableviewController的数据源与委托
    _locationSearchDisplayController.searchResultsDataSource = self;
    _locationSearchDisplayController.searchResultsDelegate   = self;
    _locationSearchDisplayController.delegate                = self;
    
}

- (void)initRefreshControl
{
    if(!self.tableView.footer)
    {
        self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreEvent)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
