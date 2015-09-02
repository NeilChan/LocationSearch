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

//接入高德地图SDK
#import <MAMapKit/MAMapKit.h>
#import "AMapApiKey.h"

@interface POIViewController ()<CLLocationManagerDelegate,UISearchDisplayDelegate,UISearchControllerDelegate,AMapSearchDelegate>
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

    
    //--------------Component-----------
    UIActivityIndicatorView *_activityIndicator;
    //系统自带定位管理，检测是否系统定位／本应用定位可用
    CLLocationManager *_locationManager;
    
    
    //--------------GD Framework-------
    //输入提示请求对象
    AMapInputTipsSearchRequest *_tipRequest;
    //关键字搜索
    AMapPlaceSearchRequest *_poiRequest;
}
@end

@implementation POIViewController

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

- (void)getReGeocode:(CLLocationCoordinate2D)location
{
    AMapReGeocodeSearchRequest *reGeocodeRequest = [[AMapReGeocodeSearchRequest alloc]init];
    
    reGeocodeRequest.searchType = AMapSearchType_ReGeocode;
    reGeocodeRequest.location = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    reGeocodeRequest.radius = 10000;
    reGeocodeRequest.requireExtension = YES;
    [_searchObj_GD AMapReGoecodeSearch:reGeocodeRequest];
}

- (void)getGeocode:(NSString *)address adcode:(NSString *)adcode
{
    if (address.length == 0) return;
    
    AMapGeocodeSearchRequest *geocodeRequest = [[AMapGeocodeSearchRequest alloc]init];
    
    geocodeRequest.searchType = AMapSearchType_Geocode;
    geocodeRequest.address = address;
    geocodeRequest.city = @[adcode];
    
    [_searchObj_GD AMapGeocodeSearch:geocodeRequest];
}

- (void)getInputTips:(NSString *)keyword
{
    
    if (!_tipRequest)
    {
        _tipRequest = [[AMapInputTipsSearchRequest alloc]init];
        _tipRequest.searchType = AMapSearchType_InputTips;
    }
    
    _tipRequest.keywords = keyword;
    _tipRequest.city = @[_currentCity];
    
    [_searchObj_GD AMapInputTipsSearch:_tipRequest];
}

- (void)searchPOI:(NSString *)name adcode:(NSString *)adcode
{
    if (!name || [name isEqualToString:@""] || !adcode || [adcode isEqualToString:@""])
    {
        return;
    }
    
    if (!_poiRequest)
    {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
    }
    
    _poiRequest.searchType       = AMapSearchType_PlaceKeyword;
    _poiRequest.keywords         = name;
    _poiRequest.city             = @[adcode];
    _poiRequest.requireExtension = YES;
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
}

- (void)searchPOI
{
    if (!_poiRequest)
    {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
    }
    
    _poiRequest.searchType       = AMapSearchType_PlaceAround;
    _poiRequest.requireExtension = YES;
    _poiRequest.page             = _currentPage;
    
    if (self.keyword && ![self.keyword isEqualToString:@""]) _poiRequest.keywords = self.keyword;
    
    if (self.type && self.type.count > 0) _poiRequest.types = self.type;
    
    if (self.currentCity && ![self.currentCity isEqualToString:@""]) _poiRequest.city = @[self.currentCity];
    
    if (self.radius > 1000) _poiRequest.radius = self.radius;
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
}

- (void)searchWithLocation:(CLLocationCoordinate2D)coordinate2D
{
    if (!_poiRequest) {
        _poiRequest = [[AMapPlaceSearchRequest alloc]init];
        _poiRequest.searchType = AMapSearchType_PlaceAround;
    }
    
    _poiRequest.location = [AMapGeoPoint locationWithLatitude:coordinate2D.latitude
                                                    longitude:coordinate2D.longitude];
    _poiRequest.types = @[@"餐饮服务",@"汽车销售",@"购物服务",@"生活服务",@"体育休闲服务",@"医疗保健服务",@"住宿服务",@"风景名胜",@"商务住宅",@"科教文化服务",@"公司企业",@"政府机构及社会团体",@"金融保险服务"];
    _poiRequest.offset           = 50;
    _poiRequest.page             = _currentPage;
    _poiRequest.requireExtension = YES;
    _poiRequest.sortrule         = 1;
    _poiRequest.radius           = 10000;
    
    [_searchObj_GD AMapPlaceSearch:_poiRequest];
}

- (void)filterData:(NSString *)searchStr
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", searchStr];
    
    _filterArr = [[_locationArr copy] filteredArrayUsingPredicate:predicate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_locationSearchDisplayController.searchResultsTableView reloadData];
    });
}

#pragma mark - AMapSearchDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode)
    {
        AMapReGeocode *result = response.regeocode;
        
        if (result.addressComponent.city)
        {
            _currentCity = result.addressComponent.city;
        }
    }
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0) return;
    
    AMapGeocode *geocode = response.geocodes[0];

    _currCoordinate2D = CLLocationCoordinate2DMake(geocode.location.latitude, geocode.location.longitude);
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if (response.tips.count == 0)
    {
        _filterArr = [[NSArray alloc]init];
        return;
    }
    
    _filterArr = response.tips;
    
    //刷新界面如果放到searchDisplayController里面自动刷新会慢一步
    dispatch_async(dispatch_get_main_queue(), ^{
        [_locationSearchDisplayController.searchResultsTableView reloadData];
    });
}

- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    NSLog(@"on place done: %@",response.pois);
    
    if(response.pois.count == 0)
    {
        return;
    }
    
    if (!_locationArr || _locationArr.count == 0) {
        _locationArr = [[NSMutableArray alloc]initWithArray:response.pois];
    }else {
        [_locationArr addObjectsFromArray:response.pois];
    }
    
    //刷新界面如果放到searchDisplayController里面自动刷新会慢一拍
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        return _locationArr.count;
    }
    
    return  _filterArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"locationSearchResult";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell)
    {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _locationSearchDisplayController.searchResultsTableView)
    {
        AMapTip *tip = _filterArr[indexPath.row];
        [self getGeocode:tip.district adcode:tip.adcode];
    }
    else if(tableView == self.tableView)
    {
        AMapPOI *poi = _locationArr[indexPath.row];
        CLLocation *location = [[CLLocation alloc]initWithLatitude:poi.location.latitude longitude:poi.location.longitude];
        MapViewBaseController *mapVC = [[MapViewBaseController alloc]initWithCCLocation:location];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _locationArr.count - 10)
    {
        [self getMoreEvent];
    }
}



#pragma mark - UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self getInputTips:searchString];
    
    //不在此刷新，因为数据会慢一步出来
    return NO;
}

#pragma mark - Custom Property Setter Or Getter

- (AMapSearchAPI *)searchObj_GD
{
    if (!_searchObj_GD)
    {
        _searchObj_GD           = [[AMapSearchAPI alloc]initWithSearchKey:self.apiKey Delegate:self];
        _searchObj_GD.language  = AMapSearchLanguage_zh_CN;
    }
    return _searchObj_GD;
}

- (void)setCurrCoordinate2D:(CLLocationCoordinate2D)currCoordinate2D
{
    _currCoordinate2D = currCoordinate2D;
    
    [self searchPOI];
}

#pragma mark - Life Cycle Of View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSearchDisplayController];
}

#pragma mark - Initialize or Dealloc

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        [self initClassData];
        
        self.apiKey = [AMapApiKey getAPIKey];
        
        [MAMapServices sharedServices].apiKey = self.apiKey;
    }
    
    return self;
}

- (instancetype)initWithApiKey:(NSString *)apiKey andStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        [self initClassData];
        
        [MAMapServices sharedServices].apiKey = apiKey;
        
        self.apiKey = apiKey;
        
        [AMapApiKey setAPIKey:apiKey];
    }
    
    return self;
}

- (void)initClassData
{
    _filterArr          = [[NSArray alloc]init];
    _currentPage        = 1;
    self.keyword        = nil;
    self.type           = @[@"餐饮服务",@"汽车销售",@"购物服务",
                            @"生活服务",@"体育休闲服务",@"医疗保健服务",
                            @"住宿服务",@"风景名胜",@"商务住宅",
                            @"科教文化服务",@"公司企业",@"政府机构及社会团体",@"金融保险服务"];
    self.radius         = 3000;
    self.poiSearchType  = AMapSearchType_PlaceAround;
    self.currentCity    = nil;
}

- (void)initSearchDisplayController
{
    LocationSearchBar *searchBar    = [[LocationSearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder           = [NSString stringWithFormat:@"%@",NSLocalizedString(@"POI搜索", @"search")];
    
    //设置为tableView的HeaderView
    self.tableView.tableHeaderView      = searchBar;
    _locationSearchDisplayController    = [[LocationSearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    
    //关联searchDisplayController与tableviewController的数据源与委托
    _locationSearchDisplayController.searchResultsDataSource = self;
    _locationSearchDisplayController.searchResultsDelegate   = self;
    _locationSearchDisplayController.delegate                = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
