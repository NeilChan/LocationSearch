//
//  MapViewBaseController.m
//  MyBaby
//
//  Created by 我的宝宝 on 15/8/21.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import "MapViewBaseController.h"
#import <MAMapKit/MAMapKit.h>
#import "OpenSetting.h"

@interface MapViewBaseController ()<MAMapViewDelegate,AMapSearchDelegate,CLLocationManagerDelegate>
{
    //Component
    CLLocationManager *_locationManager;
    UIAlertView *_alertView;
    
}
@end

@implementation MapViewBaseController
@synthesize annotation = _annotation;
@synthesize annotations = _annotations;
@synthesize mapView = _mapView;
@synthesize location = _location;
@synthesize locations = _locations;
@synthesize search = _search;

#pragma mark - Initialize

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self checkLocationServices];
    }
    return self;
}

- (instancetype)initWithCCLocation:(CLLocation *)location
{
    if (self = [super init])
    {
        self.location = [[CLLocation alloc]initWithLatitude:location.coordinate.latitude
                                                  longitude:location.coordinate.longitude];
    }
    
    return self;
}

- (instancetype)initWithCCLocations:(NSArray *)locations
{
    if (self = [super init])
    {
        self.locations = locations;
    }
    
    return self;
}

- (void)initMapView
{
    [MAMapServices sharedServices].apiKey = API_KEY;
    
    self.mapView = [[MAMapView alloc]init];
    self.mapView.frame = self.view.bounds;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)initSearch
{
    self.search.delegate = self;
}

- (void)initAnnotation
{
    self.mapView.centerCoordinate = self.location.coordinate;
    self.annotation = [[MAPointAnnotation alloc]init];
    self.annotation.coordinate = self.location.coordinate;
    
    [self.mapView addAnnotation:self.annotation];
}

- (void)initAnnotations
{
    self.annotations = [NSMutableArray array];
    
    /* Location Annotation. */
    for (CLLocation *location in self.locations) {
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
        annotation.coordinate = location.coordinate;
        [self.annotations addObject:annotation];
    }
    
    [self.mapView addAnnotations:self.annotations];
    [self.mapView showAnnotations:self.annotations animated:YES];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initMapView];
    
    if (self.location) {
        [self initAnnotation];
    }else if(self.locations) {
        [self initAnnotations];
    }else {
        _mapView.showsUserLocation = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deallocMapView];
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        static NSString *annotationReuseID = @"annotationReuseID";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseID];
        if (!annotationView) {
            annotationView = [[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseID];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.draggable = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.pinColor = MAPinAnnotationColorGreen;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    if (userLocation)
    {
        NSLog(@"I was in the mapView_GD latitude : %f ,longitude : %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        
        //定不到位
        if (userLocation.coordinate.longitude == 0 && userLocation.coordinate.latitude) return;
        
        self.location = userLocation.location;
        
        _mapView.showsUserLocation = NO;
    }
    else
    {
        NSLog(@"%s: Class = %@, errInfo= !userLocation", __func__, [self class]);
    }
}

#pragma mark - AMapSearchDelegate

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [alertView removeFromSuperview];
            //[self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
            //[self.navigationController popViewControllerAnimated:YES];
            [OpenSetting openSetting];
            break;
        default:
            break;
    }
}

#pragma mark - Check Location Services Enable
/**
 *  @brief  设置定位管理器，检测设备定位功能是否可用
 */
- (void)checkLocationServices {
    _locationManager = [[CLLocationManager alloc]init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        [self showLocationServiceEnableWarner:[NSString stringWithFormat:@"%@",NSLocalizedString(@"位置服务未开启，请到设置->隐私->定位中打开", @"Location Services haven't open. Please open it by these steps:Setting->Privacy->Location Services")]];
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showLocationServiceEnableWarner:[NSString stringWithFormat:@"%@",NSLocalizedString(@"位置服务未开启，设置后才可正常使用", @"Location Services haven't open. ")]];
    }
}

- (void)showLocationServiceEnableWarner: (NSString *)message{
    _alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"提醒", @"Remind")]
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"稍后", @"OK")]
                                 otherButtonTitles:[NSString stringWithFormat:@"%@",NSLocalizedString(@"去设置",@"Open it now")],nil];
    [_alertView show];
}

#pragma mark - Custom Property Setters

- (void)setLocation:(CLLocation *)location
{
    _location = location;
    
    [self initAnnotation];
}

- (void)setLocations:(NSArray *)locations
{
    _locations = locations;
    
    [self initAnnotations];
}

#pragma mark - Dealloc

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self deallocMapView];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deallocMapView
{
    self.mapView.showsUserLocation = NO;
    
    self.mapView.delegate = nil;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeAnnotation:self.annotation];
    
    [self.mapView removeOverlays:self.mapView.overlays];

    self.mapView = nil;
}

@end
