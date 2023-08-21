//
//  XZRefreshingView.h
//  XZRefreshing
//
//  Created by Xezun on 2023/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UIScrollView;

@protocol XZRefreshingDelegate;

/// XZRefreshingView 适配 UIScrollView 边距的方式。
typedef NS_ENUM(NSUInteger, XZRefreshingAdjustment) {
    /// 自动适配由 contentInsetAdjustmentBehavior 影响的边距。
    XZRefreshingAdjustmentAutomatic,
    /// 仅适配 UIScrollView 自身的边距。
    XZRefreshingAdjustmentNormal,
    /// 不适配边距。
    XZRefreshingAdjustmentNone,
};

/// UIScrollView 刷新视图基类。
@interface XZRefreshingView : UIView

/// 当前视图所属的 UIScrollView 视图。
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

/// 如果设置了此属性，事件将转发此对象，否则转发给 UIScrollView 的 delegate 对象。
@property (nonatomic, weak) id<XZRefreshingDelegate> delegate;

/// 适配方式。
@property (nonatomic) XZRefreshingAdjustment adjustment;
/// 是否正在（上拉加载/下拉刷新）动画。
@property (nonatomic, setter=setAnimating:) BOOL isAnimating;
/// 头部底部与可视区域之间的间距，只影响刷新视图的位置。
@property (nonatomic) CGFloat offset;

/// 进入下拉/上拉状态，并开始执行刷新动画。
/// @param animated 是否动画过度到刷新状态。
/// @param completion 动画完毕后的回调。
- (void)beginAnimating:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;
///  结束下拉/上拉状态，并停止刷新动画。
/// @param animated 是否动画过度到刷新状态。
/// @param completion 动画完毕后的回调。
- (void)endAnimating:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;

/// 进入下拉/上拉状态，并开始执行刷新动画。
/// @note 方法 -beginAnimating:completion: 的便利方法。
- (void)beginAnimating;
/// 结束下拉/上拉状态，并停止刷新动画。
/// @note 方法 -endAnimating:completion: 的便利方法。
- (void)endAnimating;

#pragma mark - 自定义刷新视图可重写的方法

/// 动画时视图展出的高度，默认值为控件自身高度。
@property (nonatomic) CGFloat animationHeight;

/// 当 UIScrollView 被下拉或上拉时，此方法会被调用。
/// @param scrollView 被上拉或下拉的 UIScrollView 对象
/// @param distance 被上拉或下拉的距离
- (void)scrollView:(UIScrollView *)scrollView didScrollDistance:(CGFloat)distance;

/// 当用户停止下拉或上拉时，此方法会被调用。
/// @note 如果此方法分返回了 YES 那么 UIScrollView 将进入刷新状态。
/// @param scrollView 被上拉或下拉的 UIScrollView 对象
/// @param distance 被上拉或下拉的距离，该距离不包括间距
/// @returns 刷新视图拖动距离 distance 是否满足进入刷新状态
- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance;

/// 当 scrollView 进入刷新状态时，此方法会被调用。
/// @param scrollView 调用此方法 UIScrollView 对象
/// @param animated 是否需要展示动画过程，用户操作触发刷新时，此参数为 NO
- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated;

/// 当 scrollView 将要停止刷新时，此方法会被调用。
/// @param scrollView 调用此方法 UIScrollView 对象
/// @param animated 停止刷新状态是否动画过渡
- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated;

/// 当 scrollView 停止刷新时，此方法会被调用。
/// @param scrollView 调用此方法 UIScrollView 对象
/// @param animated 停止刷新状态是否动画过渡
- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
