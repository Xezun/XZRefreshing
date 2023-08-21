# XZRefreshing

[![CI Status](https://img.shields.io/travis/xezun/XZRefreshing.svg?style=flat)](https://travis-ci.org/xezun/XZRefreshing)
[![Version](https://img.shields.io/cocoapods/v/XZRefreshing.svg?style=flat)](https://cocoapods.org/pods/XZRefreshing)
[![License](https://img.shields.io/cocoapods/l/XZRefreshing.svg?style=flat)](https://cocoapods.org/pods/XZRefreshing)
[![Platform](https://img.shields.io/cocoapods/p/XZRefreshing.svg?style=flat)](https://cocoapods.org/pods/XZRefreshing)

## 示例工程 Example

要运行示例工程，请在拉取代码后，先在`Pods`目录下执行`pod install`命令。

To run the example project, clone the repo, and run `pod install` from the Pods directory first.

## 环境需求 Requirements

iOS 11.0, Xcode 14.0

## 安装使用 Installation

推荐使用[CocoaPods](https://cocoapods.org)安装XZRefreshing组件。

XZRefreshing is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'XZRefreshing'
```

## 效果

XZRefreshing内置了两种刷新效果。

- XZRefreshingStyle1View：默认下拉刷新效果

<img src="./Docs/images/refreshing-style1.gif" width="75" height="50" /> 

- XZRefreshingStyle2View：默认上拉加载效果

<img src="./Docs/images/refreshing-style2.gif" width="75" height="50" />

以上两种效果都可以作为`headerRefreshingView`或`footerRefreshingView`使用。

## 如何使用

一行代码实现下拉刷新或上拉加载。

```objc
// 使用默认的下拉刷新控件
[self.tableView xz_headerRefreshingView];
// 使用默认的上拉加载控件
[self.tableView xz_footerRefreshingView];
```

实现`XZRefreshingDelegate`协议即可接收事件，默认情况下 UIScrollView 的 delegate 即为下拉刷新或上拉加载的事件接收者。

```objc
- (void)scrollView:(UIScrollView *)scrollView headerRefreshingViewDidBeginAnimating:(XZRefreshingView *)headerRefreshingView {
    // handle the pull down refreshing
    [headerRefreshingView endAnimating];
}

- (void)scrollView:(UIScrollView *)scrollView footerRefreshingViewDidBeginAnimating:(XZRefreshingView *)footerRefreshingView {
    // handle the pull up refreshing
    [footerRefreshingView endAnimating];
}
```

也可以指定事件接收者。

```objc
self.tableView.xz_headerRefreshingView.delegate = self;
self.tableView.xz_footerRefreshingView.delegate = self;
```

主动唤起刷新状态。

```objc
[self.tableView.xz_headerRefreshingView beginAnimating];
[self.tableView.xz_footerRefreshingView beginAnimating:YES completion:^(BOOL finished) {
    // the footer refreshing view is animating now
}];
```

通过`XZRefreshingView`的`adjustment`属性，可以设置适配`UIScrollView`边距的方式，支持三种模式：

- XZRefreshingAdjustmentAutomatic：自动适配由 contentInsetAdjustmentBehavior 影响的边距
- XZRefreshingAdjustmentNormal：仅适配 UIScrollView 自身的边距。
- XZRefreshingAdjustmentNone：不适配边距。

```objc
self.tableView.xz_footerRefreshingView.adjustment = XZRefreshingAdjustmentNone;
```

除适配模式外，还可以通过`offset`属性，来调整刷新视图的位置。

```
self.tableView.xz_headerRefreshingView.offset = 50; // 向上偏移 50 点
self.tableView.xz_footerRefreshingView.offset = 50; // 向下偏移 50 点
```

另外，底部刷新视图，始终布局在`UIScrollView`的底部，即使在`contentSize.height < bounds.size.height`时也是。

## 自定义

1、`XZRefreshingView`提供了完整的刷新过程事件，继承它即可自定义刷新效果，具体可参考内置的`XZRefreshingStyle1View`和`XZRefreshingStyle2View`两款刷新效果。

2、实现二楼思路，由于不同的业务，需要的二楼效果不一定相同，所以暂没有内置二楼效果。

```objc
- (void)scrollView:(UIScrollView *)scrollView didScrollDistance:(CGFloat)distance {
    if (distance < 50) {
        // 展示下拉刷新的过程
    } else if (distance < 100) {
        // 松手进入刷新，或继续下拉进入二楼
    } else if (distance < 150) {
        // 松手进入二楼
    } else {
        // 直接进入二楼
        [self.delegate enterSecondFloor:YES];
    }
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    if (distance < 50) {
        return NO;
    }
    if (distance < 100) {
        return YES; // 进入刷新状态
    }
    if (distance < 150) {
        [self.delegate enterSecondFloor:NO]; // 松手进入二楼
        return NO;
    }
    return NO; // 直接进入二楼
}


/// 处理事件
- (void)enterSecondFloor:(BOOL)type {
    UIViewController *vc = UIViewController.new;
    if (type) { // 如有必要，可以为两种不同交互方式，设计不同的转场效果
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

```

## Author

Xezun, developer@xezun.com

## License

XZRefreshing is available under the MIT license. See the LICENSE file for more info.
