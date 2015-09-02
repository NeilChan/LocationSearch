//
//  AppDelegate.m
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()
{
    MainViewController *_mainVC;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect screen = [UIScreen mainScreen].bounds;
    
    self.window = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)];
    
    [self.window makeKeyAndVisible];
    
    _mainVC = [[MainViewController alloc]init];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:_mainVC];
    
    self.window.rootViewController = nav;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
