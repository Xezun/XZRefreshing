//
//  XZRefreshingContext.h
//  XZRefreshing
//
//  Created by Xezun on 2023/8/12.
//

#import <UIKit/UIKit.h>
#import <XZRefreshing/XZRefreshingView.h>

NS_ASSUME_NONNULL_BEGIN

@class XZRefreshingView;
@protocol XZRefreshingDelegate;

typedef NS_ENUM(NSUInteger, XZRefreshingState) {
    XZRefreshingStatePendinging,
    XZRefreshingStateRefreshing,
    XZRefreshingStateRecovering,
};

@interface XZRefreshingContext : NSObject

/// 初始化。
/// - Parameters:
///   - scrollView: UIScrollView
///   - headerOrFooter: YES 表示 header ；NO 表示 footer
- (instancetype)initWithScrollView:(UIScrollView *)scrollView type:(BOOL)headerOrFooter;

@property (nonatomic, readonly, nullable) id<XZRefreshingDelegate> delegate;

@property (nonatomic, strong, nullable) XZRefreshingView *view;
/// 是否正在刷新。
@property (nonatomic) XZRefreshingState state;
@property (nonatomic) CGRect frame;
/// header 在顶部自然状态时，scrollView 的滚动位置；
/// footer 在底部自然状态时，scrollView 的滚动位置。
@property (nonatomic) CGFloat contentOffsetY;
@property (nonatomic) BOOL needsTransitionAnimation;
/// 是否需要布局
@property (nonatomic) BOOL needsLayout;

/// 因为布局依赖以下属性值，每次布局都会缓存这些值，并在后续的逻辑中使用，以避免外部更改，影响使用。
- (void)saveCurrentContext;
@property (nonatomic, readonly) XZRefreshingAdjustment adjustment;
@property (nonatomic, readonly) CGFloat animationHeight;
@property (nonatomic, readonly) CGFloat offset;
@property (nonatomic, readonly) UIEdgeInsets contentInsets;

@end

NS_ASSUME_NONNULL_END
