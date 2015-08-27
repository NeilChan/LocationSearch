//
//  MapViewBaseController.m
//  MyBaby
//
//  Created by 我的宝宝 on 15/8/21.
//  Copyright (c) 2015年 BabyZone. All rights reserved.
//

#import "MapViewBaseController.h"
#import <MAMapKit/MAMapKit.h>

@interface MapViewBaseController ()<MAMapViewDelegate,AMapSearchDelegate>

@end

@implementation MapViewBaseController
@synthesize annotation = _annotation;
@synthesize annotations = _annotations;
@synthesize mapView = _mapView;
@synthesize location = _location;
@synthesize locations = _locations;
@synthesize search = _search;

#pragma mark - Initialization

- (instancetype)initWithCCLocation:(CLLocation *)location
{
    if (self = [super init]) {
        self.location = [[CLLocation alloc]initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }
    
    return self;
}

- (instancetype)initWithCCLocations:(NSArray *)locations
{
    if (self = [super init]) {
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

#pragma mark - AMapSearchDelegate

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

#pragma mark - Life Cycle

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
//
//#pragma mark - Custom Property Setters
//
//- (void)setLocation:(CLLocation *)location
//{
//    _location = location;
//    
//    [self initAnnotation];
//    
//    [self.mapView addAnnotation:self.annotation];
//}
//
//- (void)setLocations:(NSArray *)locations
//{
//    _locations = locations;
//    
//    [self initAnnotations];
//    
//    [self.mapView addAnnotations:[self.annotations copy]];
//}
@end
