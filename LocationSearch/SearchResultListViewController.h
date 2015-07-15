//
//  SearchResultListViewController.h
//  LocationSearch
//
//  Created by 我的宝宝 on 15/7/11.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    SearchType_Normal,
    SearchType_HousingEstate,
    SearchType_hospital,
    SearchType_Kindergarden,
    SearchType_PrimarySchool
}SearchType;

@interface SearchResultListViewController : UITableViewController
@property (nonatomic, assign)BOOL isNormalSearch;
@property (nonatomic, strong)NSString *keyword;

@end
