//
//  XZRefreshingManager.m
//  XZRefreshing
//
//  Created by Xezun on 2023/8/10.
//

#import "XZRefreshingManager.h"
#import "XZRefreshingView.h"
#import "XZRefreshingStyle1View.h"
#import "XZRefreshingStyle2View.h"
#import "UIScrollView+XZRefreshing.h"
#import "XZRefreshingContext.h"
#import "XZRefreshingDefines.h"

#define mainAsync(completion, ...)  if(completion){dispatch_async(dispatch_get_main_queue(),^{completion(__VA_ARGS__);});}
#define kDelegate                   @"delegate"
#define kContentSize                @"contentSize"
#define XZGetDuration(animated)     (animated?XZRefreshingAnimationDuration:0.0)

/// 为运行时提供方法实现，并无实际作用。
@interface XZRefreshingRuntime : XZRefreshingManager
- (void)__xz_refreshing_override_scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)__xz_refreshing_exchange_scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)__xz_refreshing_override_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)__xz_refreshing_exchange_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
@end

/// 给 target 添加 selector 方法。
/// - Parameters:
///   - target: 待添加方法的类
///   - selector: 方法名
///   - source: 复制方法实现的源类
///   - selectorForOverride: 如果待添加的方法已由目标父类实现，使用此方法的实现重写
///   - selectorForExchange: 如果待添加的方法已由目标自身实现，使用此方法的实现交换（先将方法添加到目标上）
///   - _key: 判断是否已经添加方法的标记
static BOOL xz_refreshing_addMethod(Class const target, SEL const selector, Class source, SEL const selectorForOverride, SEL const selectorForExchange, const void * const _key);
// Observed keys and observing context.
static void const * const _context = &_context;


@implementation XZRefreshingManager {
    /// 是否可以开始动画。
    BOOL _shouldBeginRefreshing;
    /// 记录了 HeaderFooter 的可见高度：负数为 Header 正数为 Footer 。
    CGFloat _distance;
    
    XZRefreshingContext *_header;
    XZRefreshingContext *_footer;
}

@synthesize scrollView = _scrollView;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self != nil) {
        _scrollView = scrollView;
        
        _header = [[XZRefreshingContext alloc] initWithScrollView:scrollView type:YES];
        _footer = [[XZRefreshingContext alloc] initWithScrollView:scrollView type:NO];
        
        NSKeyValueObservingOptions const options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [_scrollView addObserver:self forKeyPath:kDelegate options:options context:(void *)_context];
        [_scrollView addObserver:self forKeyPath:kContentSize options:options context:(void *)_context];
        
        [self hookScrollViewDelegate:_scrollView.delegate];
    }
    return self;
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:kDelegate context:(void *)_context];
    [_scrollView removeObserver:self forKeyPath:kContentSize context:(void *)_context];
    _scrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != _context) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if ([keyPath isEqualToString:kContentSize]) {
        CGSize const old = [change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize const new = [change[NSKeyValueChangeNewKey] CGSizeValue];
        if (CGSizeEqualToSize(new, old)) return;
        XZLog(@"[KVO][contentSize] %@", NSStringFromCGSize(new));
        // 引发kvo的情形：
        // 1、页面大小发生改变
        // 2、下拉刷新，或上拉加载，导致页面内容变化
        [self setNeedsLayoutRefreshingViews];
        
    } else if ([keyPath isEqualToString:kDelegate]) {
        // 监听 delegate
        id<UIScrollViewDelegate> const old = change[NSKeyValueChangeOldKey];
        id<UIScrollViewDelegate> const new = change[NSKeyValueChangeNewKey];
        if (old == new) return;
        [self hookScrollViewDelegate:new];
    }
}

- (void)hookScrollViewDelegate:(nullable id<UIScrollViewDelegate> const)delegate {
    if (delegate == self) {
        return;
    }
    if (delegate == nil) {
        _scrollView.delegate = self;
        return;
    }
    
    Class  const target = delegate.class;
    Class  const source = [XZRefreshingRuntime class];
    
    // 监听 scrollViewDidScroll: 方法。
    static const void * const key1 = &key1;
    BOOL const hasExchanged1 = xz_refreshing_addMethod(target, @selector(scrollViewDidScroll:), source, @selector(__xz_refreshing_override_scrollViewDidScroll:), @selector(__xz_refreshing_exchange_scrollViewDidScroll:), key1);
    
    // 监听 scrollViewWillEndDragging:withVelocity:targetContentOffset: 方法。
    static const void * const key2 = &key2;
    BOOL const hasExchanged2 = xz_refreshing_addMethod(target, @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:), source, @selector(__xz_refreshing_override_scrollViewWillEndDragging:withVelocity:targetContentOffset:), @selector(__xz_refreshing_exchange_scrollViewWillEndDragging:withVelocity:targetContentOffset:), key2);
    
    // UIScrollView 对代理进行了优化，在设置代理时，获取了代理 scrollViewDidScroll: 的方法实现，
    // 发送事件时，直接执行 Method ，为了让动态添加的方法生效，重新设置一遍代理。
    if (hasExchanged1 || hasExchanged2) {
        _scrollView.delegate = self; // 值未改变的话，不会重新获取 method 
        _scrollView.delegate = delegate;
    }
}

- (void)refreshingViewDidLoad:(XZRefreshingView *)refreshingView {
    if (!refreshingView) return;
    refreshingView.refreshingManager = self;
    [_scrollView addSubview:refreshingView];
}

- (void)setHeaderRefreshingView:(XZRefreshingView *)headerRefreshingView {
    if (_header.view == headerRefreshingView) return;
    if (_footer.view == headerRefreshingView) return;
    [_header.view removeFromSuperview];
    _header.view = headerRefreshingView;
    [self refreshingViewDidLoad:headerRefreshingView];
    [self setNeedsLayoutHeaderRefreshingView];
}

- (void)setFooterRefreshingView:(XZRefreshingView *)footerRefreshingView {
    if (_footer.view == footerRefreshingView) return;
    if (_header.view == footerRefreshingView) return;
    [_footer.view removeFromSuperview];
    _footer.view = footerRefreshingView;
    [self refreshingViewDidLoad:footerRefreshingView];
    [self setNeedsLayoutFooterRefreshingView];
}

- (XZRefreshingView *)headerRefreshingView {
    if (_header.view != nil) {
        return _header.view;
    }
    _header.view = [[XZRefreshingStyle1View alloc] initWithFrame:CGRectMake(0, -10000, _scrollView.frame.size.width, XZRefreshingViewHeight)];
    [self refreshingViewDidLoad:_header.view];
    [self setNeedsLayoutHeaderRefreshingView];
    return _header.view;
}

- (XZRefreshingView *)footerRefreshingView {
    if (_footer.view != nil) {
        return _footer.view;
    }
    _footer.view = [[XZRefreshingStyle2View alloc] initWithFrame:CGRectMake(0, +10000, _scrollView.frame.size.width, XZRefreshingViewHeight)];
    [self refreshingViewDidLoad:_footer.view];
    [self setNeedsLayoutFooterRefreshingView];
    return _footer.view;
}

- (XZRefreshingView *)headerRefreshingViewIfLoaded {
    return _header.view;
}

- (XZRefreshingView *)footerRefreshingViewIfLoaded {
    return _footer.view;
}

- (void)setNeedsLayoutHeaderRefreshingView {
    if (_header.needsLayout) {
        return;
    }
    _header.needsLayout = YES;
    [NSRunLoop.mainRunLoop performBlock:^{
        [self layoutHeaderRefreshingViewIfNeeded];
    }];
}

- (void)setNeedsLayoutFooterRefreshingView {
    if (_footer.needsLayout) {
        return;
    }
    _footer.needsLayout = YES;
    [NSRunLoop.mainRunLoop performBlock:^{
        [self layoutFooterRefreshingViewIfNeeded];
    }];
}

- (void)setNeedsLayoutRefreshingViews {
    [self setNeedsLayoutHeaderRefreshingView];
    [self setNeedsLayoutFooterRefreshingView];
}

- (void)layoutRefreshingViewsIfNeeded {
    [self layoutHeaderRefreshingViewIfNeeded];
    [self layoutFooterRefreshingViewIfNeeded];
}

// 顶部刷新视图默认布局在可视区域之上，即视图的底部与可视区域的顶部对齐 -contentInsets.top - h ，在此基础之上，按 offset 向上偏移 -offset 。
// 在动画时，contentInsets.top 相比原始值多一个 animationHeight，因此先计算出原始的 top 值，即 contentInsets.top - _header.view.animationHeight
- (void)layoutHeaderRefreshingViewIfNeeded {
    if (!_header.needsLayout) return;
    _header.needsLayout = NO;
    if (!_header.view) return;
    XZLog(@"%s", __PRETTY_FUNCTION__);
    [_header saveCurrentContext];
    
    CGRect       const bounds        = _scrollView.bounds;
    UIEdgeInsets const contentInsets = _header.contentInsets;
    
    if (_header.state == XZRefreshingStateRefreshing) {
        CGFloat const w = CGRectGetWidth(bounds);
        CGFloat const h = CGRectGetHeight(_header.frame);
        CGFloat const x = CGRectGetMinX(bounds);
        CGFloat const y = -contentInsets.top + _header.animationHeight - h;
        _header.contentOffsetY = -_scrollView.adjustedContentInset.top;
        _header.frame = CGRectMake(x, y - _header.offset, w, h);
    } else {
        CGFloat const w = CGRectGetWidth(bounds);
        CGFloat const h = CGRectGetHeight(_header.frame);
        CGFloat const x = CGRectGetMinX(bounds);
        CGFloat const y = -contentInsets.top - h;
        _header.contentOffsetY = -_scrollView.adjustedContentInset.top;
        _header.frame = CGRectMake(x, y - _header.offset, w, h);
        
        // 布局改变后，相关的参数可能发生了变化，需要重新确定下拉的状态。
        if (_header.state == XZRefreshingStatePendinging) {
            [self didScrollToHeader:_scrollView.contentOffset];
        }
    }
}

/// 底部刷新视图的布局规则：
/// 不刷新时，布局在页面底部，以 top + minHeight + bottom 撑满一屏为最小高度。
/// 正刷新时，如果页面实际高度，不满足一屏，仍然在底部刷新，满足一屏，在页面底部刷新。
- (void)layoutFooterRefreshingViewIfNeeded {
    if (!_footer.needsLayout) return;
    _footer.needsLayout = NO;
    XZLog(@"%s", __PRETTY_FUNCTION__);
    if (!_footer.view) return;
    
    [_footer saveCurrentContext];
    
    CGRect       const bounds        = _scrollView.bounds;
    CGSize       const contentSize   = _scrollView.contentSize;
    UIEdgeInsets const contentInsets = _footer.contentInsets;
    UIEdgeInsets const adjustedContentInsets = _scrollView.adjustedContentInset; // 底部布局依赖于顶部的实际边距
    
    if (_footer.state == XZRefreshingStateRefreshing) {
        CGFloat const w = CGRectGetWidth(bounds);
        CGFloat const h = CGRectGetHeight(_footer.frame);
        CGFloat const x = CGRectGetMinX(bounds);
        if (adjustedContentInsets.top + contentSize.height + adjustedContentInsets.bottom < bounds.size.height) {
            _footer.contentOffsetY = -adjustedContentInsets.top;
            CGFloat y = bounds.size.height - adjustedContentInsets.top - adjustedContentInsets.bottom + contentInsets.bottom - _footer.animationHeight;
            _footer.frame = CGRectMake(x, y + _footer.offset, w, h);
        } else {
            _footer.contentOffsetY = contentSize.height + adjustedContentInsets.bottom - bounds.size.height;
            CGFloat y = contentSize.height + contentInsets.bottom - _footer.animationHeight;
            _footer.frame = CGRectMake(x, y + _footer.offset, w, h);
        }
    } else if (_header.state == XZRefreshingStateRefreshing) {
        CGFloat const minHeight = MAX(bounds.size.height - (adjustedContentInsets.top - _header.animationHeight) - adjustedContentInsets.bottom, contentSize.height);
        CGFloat const w = CGRectGetWidth(bounds);
        CGFloat const h = CGRectGetHeight(_footer.frame);
        CGFloat const x = CGRectGetMinX(bounds);
        CGFloat const y = minHeight + contentInsets.bottom;
        _footer.contentOffsetY = MAX(minHeight + adjustedContentInsets.bottom - bounds.size.height, -adjustedContentInsets.top);
        _footer.frame = CGRectMake(x, y + _footer.offset, w, h);
    } else {
        CGFloat const minHeight = MAX(bounds.size.height - adjustedContentInsets.top - adjustedContentInsets.bottom, contentSize.height);
        CGFloat const w = CGRectGetWidth(bounds);
        CGFloat const h = CGRectGetHeight(_footer.frame);
        CGFloat const x = CGRectGetMinX(bounds);
        CGFloat const y = minHeight + contentInsets.bottom;
        _footer.contentOffsetY = MAX(minHeight + adjustedContentInsets.bottom - bounds.size.height, -adjustedContentInsets.top);
        _footer.frame = CGRectMake(x, y + _footer.offset, w, h);
        
        if (_footer.state == XZRefreshingStatePendinging) {
            [self didScrollToFooter:_scrollView.contentOffset];
        }
    }
}

/// 判断指定的 HeaderFooterView 是否在动画中。
- (BOOL)isRefreshingViewAnimating:(XZRefreshingView *)refreshingView {
    if (refreshingView == _header.view) {
        return _header.state == XZRefreshingStateRefreshing;
    }
    if (refreshingView == _footer.view) {
        return _footer.state == XZRefreshingStateRefreshing;
    }
    return NO;
}

- (void)refreshingView:(XZRefreshingView *)headerFooterView beginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (headerFooterView == _header.view) {
        [self headerRefreshingViewBeginAnimating:animated completion:completion];
    } else if (headerFooterView == _footer.view) {
        [self footerRefreshingViewBeginAnimating:animated completion:completion];
    } else {
        mainAsync(completion, NO);
    }
}

- (void)headerRefreshingViewBeginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_header.view == nil || _header.state != XZRefreshingStatePendinging || _footer.state != XZRefreshingStatePendinging) {
        mainAsync(completion, NO);
        return;
    }
    [self layoutHeaderRefreshingViewIfNeeded];
    
    _header.state = XZRefreshingStateRefreshing;
    [self headerRefreshingViewAnimatingDidBeginAnimating:animated];
    
    // 因为动画的高度不一定是下拉刷新所需的距离，所以使用 -setContentOffset:animated: 方法未必能触发刷新。
    // 因此这里使用 UIViewAnimation 的方法，直接进入下拉刷新状态。
    CGFloat const y = -_scrollView.adjustedContentInset.top;
    [UIView animateWithDuration:XZGetDuration(animated) animations:^{
        self->_scrollView.contentOffset = CGPointMake(0, y);
    } completion:completion];
}

- (void)footerRefreshingViewBeginAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_footer.view == nil || _footer.state != XZRefreshingStatePendinging || _header.state != XZRefreshingStatePendinging) {
        mainAsync(completion, NO);
        return;
    }
    [self layoutFooterRefreshingViewIfNeeded];
    
    _footer.state = XZRefreshingStateRefreshing;
    [self footerRefreshingViewAnimatingDidBeginAnimating:animated];
    
    CGSize       const contentSize   = _scrollView.contentSize;
    UIEdgeInsets const contentInsets = _scrollView.adjustedContentInset;
    CGFloat      const height        = _scrollView.bounds.size.height;
    CGFloat      const y             = MAX(contentSize.height + contentInsets.bottom - height, -contentInsets.top);
    [UIView animateWithDuration:XZGetDuration(animated) animations:^{
        self->_scrollView.contentOffset = CGPointMake(0, y);
        
        [self setNeedsLayoutFooterRefreshingView];
        [self layoutFooterRefreshingViewIfNeeded];
    } completion:completion];
}

- (void)refreshingView:(XZRefreshingView *)refreshingView endAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (refreshingView == _header.view) {
        [self headerRefreshingViewEndAnimating:animated completion:completion];
    } else if (refreshingView == _footer.view) {
        [self footerRefreshingEndAnimating:animated completion:completion];
    } else {
        mainAsync(completion, NO);
    }
}

- (void)headerRefreshingViewEndAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_header.state != XZRefreshingStateRefreshing) {
        mainAsync(completion, NO);
        return;
    }
    //[self layoutHeaderRefreshingViewIfNeeded];
    
    CGPoint const contentOffset = _scrollView.contentOffset;
    
    UIEdgeInsets newContentInsets  = _scrollView.contentInset;
    newContentInsets.top -= _header.animationHeight;
    
    if (contentOffset.y >= _header.contentOffsetY + _header.animationHeight) {
        // 顶部刷新视图不在展示区域内，不需要展示结束动画
        _scrollView.contentInset  = newContentInsets;
        _scrollView.contentOffset = contentOffset;
        _header.state = XZRefreshingStateRecovering; // set NO after setting contentInset/contentOffset to prevent scrollViewDidScroll: checking.
        [_header.view scrollView:_scrollView willEndRefreshing:NO];
        
        // 布局并记录状态
        [self setNeedsLayoutHeaderRefreshingView];
        [self layoutHeaderRefreshingViewIfNeeded];
        
        _header.state = XZRefreshingStatePendinging;
        [_header.view scrollView:_scrollView didEndRefreshing:NO];
        mainAsync(completion, NO);
    } else {
        _scrollView.contentInset  = newContentInsets;
        _scrollView.contentOffset = contentOffset;
        _header.state = XZRefreshingStateRecovering;
        
        // 布局并记录状态
        [self setNeedsLayoutHeaderRefreshingView];
        [self layoutHeaderRefreshingViewIfNeeded];
        
        CGFloat const y = -_scrollView.adjustedContentInset.top;
        [UIView animateWithDuration:XZGetDuration(animated) animations:^{
            self->_scrollView.contentOffset = CGPointMake(contentOffset.x, y);
            [self->_header.view scrollView:self->_scrollView willEndRefreshing:animated];
        } completion:^(BOOL finished) {
            self->_header.state = XZRefreshingStatePendinging;
            [self->_header.view scrollView:self->_scrollView didEndRefreshing:animated];
            mainAsync(completion, finished);
        }];
    }
}

- (void)footerRefreshingEndAnimating:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (_footer.state != XZRefreshingStateRefreshing) {
        mainAsync(completion, NO);
        return;
    }
    //[self layoutFooterRefreshingViewIfNeeded];
    
    CGRect  const bounds        = _scrollView.bounds;
    CGSize  const contentSize   = _scrollView.contentSize;
    CGPoint const contentOffset = _scrollView.contentOffset;
    
    UIEdgeInsets newContentInsets = _scrollView.contentInset;
    newContentInsets.bottom -= _footer.animationHeight;
    
    if (contentOffset.y <= _footer.contentOffsetY - _footer.animationHeight) {
        // 底部刷新视图没有在展示区域内，页面不需要动
        // 下拉加载更多后，footer 已经不展示在可见范围，footer 的动画在 kvo 时处理了
        _scrollView.contentInset  = newContentInsets;
        _scrollView.contentOffset = contentOffset;
        _footer.state = XZRefreshingStateRecovering;
        [_footer.view scrollView:_scrollView willEndRefreshing:NO];
        
        // 布局并记录状态
        [self setNeedsLayoutFooterRefreshingView];
        [self layoutFooterRefreshingViewIfNeeded];
        
        _footer.state = XZRefreshingStatePendinging;
        [self->_footer.view scrollView:self->_scrollView didEndRefreshing:NO];
        mainAsync(completion, NO);
    } else {
        _scrollView.contentInset = newContentInsets;
        _scrollView.contentOffset = contentOffset;
        _footer.state = XZRefreshingStateRecovering;
        
        [UIView animateWithDuration:XZGetDuration(animated) animations:^{
            UIEdgeInsets const contentInsets = self->_scrollView.adjustedContentInset;
            CGFloat      const          maxY = MAX(contentSize.height + contentInsets.bottom - bounds.size.height, -contentInsets.top);
            
            // 布局并记录状态
            [self setNeedsLayoutFooterRefreshingView];
            [self layoutFooterRefreshingViewIfNeeded];
            
            if (contentOffset.y > maxY) {
                self->_scrollView.contentOffset = CGPointMake(contentOffset.x, maxY);
            }
            [self->_footer.view scrollView:self->_scrollView willEndRefreshing:animated];
        } completion:^(BOOL finished) {
            self->_footer.state = XZRefreshingStatePendinging;
            [self->_footer.view scrollView:self->_scrollView didEndRefreshing:animated];
            mainAsync(completion, finished);
        }];
    }
}

#pragma mark - <UIScrollViewDelegate>

/// 滚动到了 header
/// @attention 才能调用此方法时，需先确定当前 header 处于 pending 状态。
- (BOOL)didScrollToHeader:(CGPoint)contentOffset {
    // 判断是否进入下拉刷新
    if (contentOffset.y > _header.contentOffsetY) {
        return NO;
    }
    // 如果上一个状态是上拉加载，通知 footer 上拉已经结束了。
    if (_distance > 0) {
        [_footer.view scrollView:_scrollView didScrollDistance:0];
    }
    // 通知 header
    _distance = contentOffset.y - _header.contentOffsetY;
    [_header.view scrollView:_scrollView didScrollDistance:-_distance];
    return YES;
    
}

/// @attention 才能调用此方法时，需先确定当前 footer 处于 pending 状态。
- (BOOL)didScrollToFooter:(CGPoint)contentOffset {
    // 判断是否进入了上拉加载
    if (contentOffset.y < _footer.contentOffsetY) {
        return NO;
    }
    // 如果上一个状态是上拉加载，通知 header 下拉已经结束了。
    if (_distance < 0) {
        [_header.view scrollView:_scrollView didScrollDistance:0];
    }
    _distance = contentOffset.y - _footer.contentOffsetY;
    [_footer.view scrollView:_scrollView didScrollDistance:_distance];
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return;
    }
    if (_header.state != XZRefreshingStatePendinging) {
        return;
    }
    if (_footer.state == XZRefreshingStateRecovering) {
        return;
    }
    
    CGPoint const contentOffset = _scrollView.contentOffset;
    XZLog(@"%s %@", __PRETTY_FUNCTION__, NSStringFromCGPoint(contentOffset));
    
    if (_footer.state == XZRefreshingStateRefreshing) {
        if (!_footer.needsTransitionAnimation) return;
        CGRect  const frame = _footer.frame;
        CGFloat const delta = CGRectGetMinY(frame) - _footer.contentOffsetY;
        
        CGRect viewFrame = _footer.view.frame;
        if (CGRectGetMinY(viewFrame) - contentOffset.y < delta) {
            return;
        }
        
        if (contentOffset.y > _footer.contentOffsetY) {
            viewFrame.origin.y = contentOffset.y + delta;
            _footer.view.frame = viewFrame;
        } else {
            _footer.view.frame = _footer.frame;
            _footer.needsTransitionAnimation = NO;
        }
        return;
    }
    
    // 下拉刷新
    if (_header.view != nil) {
        // 进入下拉状态。
        if ([self didScrollToHeader:contentOffset]) {
            return;
        }
        
        // 结束上拉
        if (_distance < 0) {
            _distance = 0;
            [_header.view scrollView:_scrollView didScrollDistance:-_distance];
        }
    }
    
    if (_footer.view != nil) {
        if ([self didScrollToFooter:contentOffset]) {
            return;
        }
        
        if (_distance > 0) {
            _distance = 0;
            [_footer.view scrollView:_scrollView didScrollDistance:_distance];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView != _scrollView || _header.state != XZRefreshingStatePendinging || _footer.state != XZRefreshingStatePendinging) {
        return;
    }
    
    if (_distance < 0) {
        if (![_header.view scrollView:_scrollView shouldBeginRefreshing:-_distance]) {
            return;
        }
        _distance = 0;
        _header.state = XZRefreshingStateRefreshing;
        [self headerRefreshingViewAnimatingDidBeginAnimating:NO];
        
        // 布局并记录状态
        [self setNeedsLayoutHeaderRefreshingView];
        [self layoutHeaderRefreshingViewIfNeeded];
        
        UIEdgeInsets const contentInsets = _scrollView.adjustedContentInset;
        targetContentOffset->y = -contentInsets.top;
        
        id<XZRefreshingDelegate> const delegate = _header.delegate;
        if ([delegate respondsToSelector:@selector(scrollView:headerRefreshingViewDidBeginAnimating:)]) {
            [delegate scrollView:_scrollView headerRefreshingViewDidBeginAnimating:_header.view];
        }
        return;
    }
    
    if (_distance > 0) {
        if (![_footer.view scrollView:_scrollView shouldBeginRefreshing:_distance]) {
            return;
        }
        _distance = 0;
        _footer.state = XZRefreshingStateRefreshing;
        [self footerRefreshingViewAnimatingDidBeginAnimating:NO];
        
        CGRect       const bounds        = _scrollView.bounds;
        CGSize       const contentSize   = _scrollView.contentSize;
        UIEdgeInsets const adjustedContentInset = _scrollView.adjustedContentInset;
        
        // 回弹的目标位置
        targetContentOffset->y = MAX(contentSize.height + adjustedContentInset.bottom - bounds.size.height, -adjustedContentInset.top);
        
        CGRect const oldFrame = _footer.frame;
        // 布局并记录状态
        [self setNeedsLayoutFooterRefreshingView];
        [self layoutFooterRefreshingViewIfNeeded];
        // 如果 footer 的位置，在动画前后不一致，先恢复当前位置，然后跟随 scrollView 滚动到目标位置。
        CGRect const newFrame = _footer.frame;
        if (CGRectGetMinY(newFrame) < CGRectGetMinY(oldFrame)) {
            _footer.view.frame = oldFrame; // 保存了 context 的值
            _footer.needsTransitionAnimation = YES;
        }
        
        id<XZRefreshingDelegate> const delegate = _footer.delegate;
        if ([delegate respondsToSelector:@selector(scrollView:footerRefreshingViewDidBeginAnimating:)]) {
            [delegate scrollView:_scrollView footerRefreshingViewDidBeginAnimating:_footer.view];
        }
        return;
    }
}

- (void)headerRefreshingViewAnimatingDidBeginAnimating:(BOOL)animated {
    CGPoint const contentOffset = _scrollView.contentOffset;
    
    // 增加到 contentInset 的边距会叠加到 adjustedContentInset 中
    // 改变 contentInset 会触发 didScroll 方法，可能改变 contentOffset
    UIEdgeInsets contentInsets  = _scrollView.contentInset;
    contentInsets.top += _header.animationHeight;
    _scrollView.contentInset  = contentInsets;
    
    _scrollView.contentOffset = contentOffset;
    
    [_header.view scrollView:_scrollView didBeginRefreshing:animated];
}

- (void)footerRefreshingViewAnimatingDidBeginAnimating:(BOOL)animated {
    CGPoint const contentOffset = _scrollView.contentOffset;
    
    UIEdgeInsets contentInsets  = _scrollView.contentInset;
    contentInsets.bottom += _footer.animationHeight;
    _scrollView.contentInset = contentInsets;

    _scrollView.contentOffset = contentOffset;
    
    [_footer.view scrollView:_scrollView didBeginRefreshing:animated];
}

@end

#import <objc/runtime.h>

// Association keys.
static const void * const _manager = &_manager;

@implementation UIScrollView (XZRefreshingManager)

+ (void)load {
    if (self == UIScrollView.class) {
        Method const oldMethod = class_getInstanceMethod(UIScrollView.class, @selector(adjustedContentInsetDidChange));
        Method const newMethod = class_getInstanceMethod(UIScrollView.class, @selector(__xz_refreshing_exchange_adjustedContentInsetDidChange));
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

- (XZRefreshingManager *)xz_refreshingManager {
    XZRefreshingManager *refreshingManager = objc_getAssociatedObject(self, _manager);
    if (refreshingManager != nil) {
        return refreshingManager;
    }
    refreshingManager = [[XZRefreshingManager alloc] initWithScrollView:self];
    objc_setAssociatedObject(self, _manager, refreshingManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return refreshingManager;
}

- (XZRefreshingManager *)xz_refreshingManagerIfLoaded {
    return objc_getAssociatedObject(self, _manager);
}

- (void)__xz_refreshing_exchange_adjustedContentInsetDidChange {
    [self __xz_refreshing_exchange_adjustedContentInsetDidChange];
    
    [self.xz_refreshingManagerIfLoaded setNeedsLayoutRefreshingViews];
}

@end


@implementation XZRefreshingRuntime

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshingManagerIfLoaded scrollViewDidScroll:scrollView];
}

- (void)__xz_refreshing_override_scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshingManagerIfLoaded scrollViewDidScroll:scrollView];
    [super scrollViewDidScroll:scrollView];
}

- (void)__xz_refreshing_exchange_scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView.xz_refreshingManagerIfLoaded scrollViewDidScroll:scrollView];
    [self __xz_refreshing_exchange_scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [scrollView.xz_refreshingManagerIfLoaded scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)__xz_refreshing_override_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [scrollView.xz_refreshingManagerIfLoaded scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [super scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)__xz_refreshing_exchange_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [scrollView.xz_refreshingManagerIfLoaded scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    [self __xz_refreshing_exchange_scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

@end

static Method xz_refreshing_getInstanceMethod(Class const target, SEL const selector) {
    Method method = NULL;
    
    unsigned int count = 0;
    Method *methods = class_copyMethodList(target, &count);
    for (unsigned int i = 0; i < count; i++) {
        if (method_getName(methods[i]) == selector) {
            method = methods[i];
            break;
        }
    }
    free(methods);
    
    return method;
}

static BOOL xz_refreshing_addMethod(Class const target, SEL const selector, Class source, SEL const selectorForOverride, SEL const selectorForExchange, const void * const _key) {
    if (objc_getAssociatedObject(target, _key)) return NO;
    
    // 方法已实现
    if ([target instancesRespondToSelector:selector]) {
        Method const oldMethod = xz_refreshing_getInstanceMethod(target, selector);
        if (oldMethod == NULL) {
            // 方法由父类实现，自身未实现，重写方法
            Method      const mtd = class_getInstanceMethod(source, selectorForOverride);
            IMP         const imp = method_getImplementation(mtd);
            const char *const enc = method_getTypeEncoding(mtd);
            class_addMethod(target, selector, imp, enc);
        } else {
            // 方法已自身实现，先添加被交换的方法，然后交换实现
            Method sourceMethod = class_getInstanceMethod(source, selectorForExchange);
            IMP sourceIMP = method_getImplementation(sourceMethod);
            if (class_addMethod(target, selectorForExchange, sourceIMP, method_getTypeEncoding(sourceMethod))) {
                Method const newMethod = class_getInstanceMethod(target, selectorForExchange);
                method_exchangeImplementations(oldMethod, newMethod);
            }
        }
    } else {
        // 方法未实现，添加方法
        Method       const mtd = class_getInstanceMethod(source, selector);
        IMP          const imp = method_getImplementation(mtd);
        const char * const enc = method_getTypeEncoding(mtd);
        class_addMethod(target, selector, imp, enc);
    }
    
    objc_setAssociatedObject(target, _key, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    return YES;
}

