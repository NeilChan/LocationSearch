//
//  ViewController.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "MainViewController.h"
#import "MapViewBaseController.h"
#import "SearchResultListViewController.h"

@interface MainViewController ()
{
    
    
}
@end

@implementation MainViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
