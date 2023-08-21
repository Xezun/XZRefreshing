//
//  UIScrollView+XZRefreshing.h
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XZRefreshing/XZRefreshingView.h>

NS_ASSUME_NONNULL_BEGIN

/// 过渡动画所使用的时长。
FOUNDATION_EXPORT NSTimeInterval const XZRefreshingAnimationDuration;
/// 默认刷新视图的高度。
FOUNDATION_EXPORT CGFloat        const XZRefreshingViewHeight;

@class XZRefreshingView;

/// 本协议指定了接收 XZRefreshing 事件的方法。
/// @note 事件接收者为 UIScrollView 的代理。
@protocol XZRefreshingDelegate <NSObject>
@optional
/// 当头部视图开始动画时，此方法会被调用。
/// @param scrollView 触发此方法的 UIScrollView 对象。
/// @param headerRefreshingView 已开始动的 XZRefreshingView 对象。
- (void)scrollView:(UIScrollView *)scrollView headerRefreshingViewDidBeginAnimating:(XZRefreshingView *)headerRefreshingView;
/// 当底部视图开始动画时，此方法会被调用。
/// @param scrollView 触发此方法的 UIScrollView 对象。
/// @param footerRefreshingView 已开始动画的 XZRefreshingView 对象。
- (void)scrollView:(UIScrollView *)scrollView footerRefreshingViewDidBeginAnimating:(XZRefreshingView *)footerRefreshingView;
@end

@interface UIScrollView (XZRefreshing)

/// 顶部刷新视图。
/// @discussion 懒加载，默认为 XZRefreshingStyle1View 刷新样式。
@property (nonatomic, strong, null_resettable, setter=xz_setHeaderRefreshingView:) __kindof XZRefreshingView *xz_headerRefreshingView;
/// 顶部刷新视图，非懒加载。
@property (nonatomic, strong, nullable, readonly) __kindof XZRefreshingView *xz_headerRefreshingViewIfNeeded;
/// 底部刷新视图。
/// @discussion 懒加载，默认为 XZRefreshingStyle2View 刷新样式。
@property (nonatomic, strong, null_resettable, setter=xz_setFooterRefreshingView:) __kindof XZRefreshingView *xz_footerRefreshingView;
/// 底部刷新视图，非懒加载。
@property (nonatomic, strong, nullable, readonly) __kindof XZRefreshingView *xz_footerRefreshingViewIfNeeded;

/// 标记需要重新布局刷新视图。
- (void)xz_setNeedsLayoutRefreshingViews;
/// 根据需要重新布局刷新视图。
- (void)xz_layoutRefreshingViewsIfNeeded;

@end

NS_ASSUME_NONNULL_END
