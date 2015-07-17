##LocationSearch
集成高德地图SDK。坐标系一致采用高德地图坐标。使用高德地图进行定位解析坐标。
实现类似微博或者陌陌上的显示附近位置信息功能。
也可自行按关键字搜索。

![image](https://github.com/ChenNan-FRAM/LocationSearch/blob/master/LocationSearch/LocationSearch.gif)

##### 需导入框架
需要导入系统自带框架有：

- UIKit.framework
- Foundation.framework
- CoreGraphics.framework
- CoreTelephony.framework
- SystemConfiguration.framework
- libz.dylib
- libstdc++6.09.dylib

高德地图框架：

- AMapSearchKit.framework
- MAMapKit.framework

##### 使用方法
在需要使用的地方导入"SearchResultListViewController.h"

如果是使用关键字搜索：
```
SearchResultListViewController *search = [[SearchResultListViewController alloc]initWithApiKey:@"你的APIKey" andStyle:UITableViewStylePlain];
search.keyword = @"幼儿园";
```

如果是查看附近位置：
```
SearchResultListViewController *search = [[SearchResultListViewController alloc]initWithApiKey:@"你的APIKey" andStyle:UITableViewStylePlain];
search.isNormalSearch = true;
```

如果需要指定搜索的范围：
```
search.radius = NSInteger;
```
###### 注：高德APIKey是需要自行在高德地图开发平台注册
