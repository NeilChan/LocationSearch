//
//  ViewController.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "MainViewController.h"
#import "MapViewBaseController.h"
#import "POIViewController.h"

@interface MainViewController ()
{
    NSString *_currentCity;
    
    CLLocationCoordinate2D  _currCoordinate2D;
    
}
@end

@implementation MainViewController

#pragma mark - Life Cycle

- (void)loadView
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.contentSize                    = CGSizeMake(IPHONE_WIGHT, IPHONE_HEIGHT + 64);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator   = NO;
    self.view = scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubView];
}

- (void)initSubView
{
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self initMapVC];
    
    [self initPoiVC];
}

- (void)initMapVC
{
    self.mapVC.view.frame = CGRectMake(0, 0, IPHONE_WIGHT, IPHONE_HEIGHT * 2 / 5);
    
    [self.view addSubview:self.mapVC.view];
    
    [self addChildViewController:self.mapVC];
}

- (void)initPoiVC
{
    CGFloat originY_mapVC = CGRectGetMaxY(self.mapVC.view.frame);
    
    self.poiVC.view.frame = CGRectMake(0, originY_mapVC, IPHONE_WIGHT, IPHONE_HEIGHT * 3 / 5 - 44);
    
    [self.view addSubview:self.poiVC.view];
    
    [self addChildViewController:self.mapVC];
}

#pragma mark - Lazy Load

- (MapViewBaseController *)mapVC
{
    if (!_mapVC)
    {
        _mapVC = [[MapViewBaseController alloc]init];
    }
    return _mapVC;
}

- (POIViewController *)poiVC
{
    if (!_poiVC)
    {
        _poiVC = [[POIViewController alloc]initWithStyle:UITableViewStyleGrouped];
    }
    
    return _poiVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//#pragma mark - ChangeController
//- (void)changeTableView
//{
//    
//    if ((_currentVC == _userInfoView && _segmentControl.selectedSegmentIndex == 0)||
//        (_currentVC == _albumView && _segmentControl.selectedSegmentIndex == 1)) {
//        return;
//    }
//    else{
//        switch (_segmentControl.selectedSegmentIndex) {
//            case 0:
//                [self replaceController:_currentVC newController:_userInfoView];
//                _refreshView.contentSize = CGSizeMake(IPHONE_SCREEN_WIDTH, _userInfoView.view.frame.size.height + CGRectGetMaxY(_segmentControl.frame));
//                break;
//            case 1:
//                [self replaceController:_currentVC newController:_albumView];
//                _refreshView.contentSize = CGSizeMake(IPHONE_SCREEN_WIDTH, _albumView.view.frame.size.height + CGRectGetMaxY(_segmentControl.frame));
//                break;
//                
//            default:
//                [_weiboTableView.view removeFromSuperview];
//                break;
//        }
//    }
//}
//- (void)replaceController: (UIViewController *)oldController newController:(UIViewController *)newController {
//    [self addChildViewController:newController];
//    [self transitionFromViewController:oldController
//                      toViewController:newController
//                              duration:2.0
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:nil
//                            completion:^(BOOL finished){
//                                
//                                if(finished) {
//                                    [newController didMoveToParentViewController:self];
//                                    [oldController willMoveToParentViewController:nil];
//                                    [oldController removeFromParentViewController];
//                                    _currentVC = newController;
//                                }
//                                else {
//                                    _currentVC = oldController;
//                                }
//                            }];
//}


@end
