//
//  XZRefreshingManager.h
//  XZRefreshing
//
//  Created by Xezun on 2023/8/10.
//

#import <Foundation/Foundation.h>
#import <XZRefreshing/XZRefreshingView.h>

NS_ASSUME_NONNULL_BEGIN


/// 管理了 HeaderFooter 的布局和动画。
@interface XZRefreshingManager : NSObject <UIScrollViewDelegate>

@property (nonatomic, weak, readonly)  UIScrollView *scrollView;

@property (nonatomic, strong, null_resettable)    XZRefreshingView *headerRefreshingView;
@property (nonatomic, strong, nullable, readonly) XZRefreshingView *headerRefreshingViewIfLoaded;

@property (nonatomic, strong, null_resettable)    XZRefreshingView *footerRefreshingView;
@property (nonatomic, strong, nullable, readonly) XZRefreshingView *footerRefreshingViewIfLoaded;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (void)setNeedsLayoutRefreshingViews;
- (void)layoutRefreshingViewsIfNeeded;

- (BOOL)isRefreshingViewAnimating:(XZRefreshingView *)refreshingView;
- (void)refreshingView:(XZRefreshingView *)refreshingView beginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)refreshingView:(XZRefreshingView *)refreshingView endAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion;
@end

@interface UIScrollView (XZRefreshingManager)
@property (nonatomic, strong, readonly) XZRefreshingManager *xz_refreshingManager;
@property (nonatomic, strong, readonly, nullable) XZRefreshingManager *xz_refreshingManagerIfLoaded;
@end

/// 在 XZRefreshingView.m 中实现。
@interface XZRefreshingView (XZRefreshingManager)
/// 管理当前视图的 XZRefreshingManager 对象。
@property (nonatomic, weak) XZRefreshingManager *refreshingManager;
@end

NS_ASSUME_NONNULL_END
