//
//  XZRefreshingContext.m
//  XZRefreshing
//
//  Created by Xezun on 2023/8/12.
//

#import "XZRefreshingContext.h"
#import "XZRefreshingView.h"
#import "UIScrollView+XZRefreshing.h"
#import "XZRefreshingDefines.h"

@implementation XZRefreshingContext {
    /// YES 表示 header
    BOOL _type;
    UIScrollView * __weak _scrollView;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView type:(BOOL)headerOrFooter {
    self = [super init];
    if (self) {
        _type = headerOrFooter;
        _state = XZRefreshingStatePendinging;
        _scrollView = scrollView;
        // 事件 scrollViewDidScroll 的触发可能比视图布局更早，避免事件发生时，此值不对而判断错了状态。
        _contentOffsetY = headerOrFooter ? -CGFLOAT_MAX : +CGFLOAT_MAX;
        _needsTransitionAnimation = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    _frame = frame;
    _view.frame = frame;
}

- (void)saveCurrentContext {
    _frame = _view.frame;
    _adjustment = _view.adjustment;
    // 处于刷新状态时，旧 animationHeight 被补充到了 contentInset 中，
    // 后续恢复原始值依赖于此，因此不能更改。
    if (_state != XZRefreshingStateRefreshing) {
        _animationHeight = _view.animationHeight;
    }
    _offset = _view.offset;
}

- (UIEdgeInsets)contentInsets {
    switch (_adjustment) {
        case XZRefreshingAdjustmentAutomatic:
            return _scrollView.adjustedContentInset;
        case XZRefreshingAdjustmentNormal:
            return _scrollView.contentInset;
        case XZRefreshingAdjustmentNone: {
            if (_state == XZRefreshingStateRefreshing) {
                if (_type) {
                    return UIEdgeInsetsMake(_animationHeight, 0, 0, 0);
                }
                return UIEdgeInsetsMake(0, 0, _animationHeight, 0);
            }
            return UIEdgeInsetsZero;
        }
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:@"不支持的适配模式" userInfo:nil];
    }
}

- (id<XZRefreshingDelegate>)delegate {
    return _view.delegate ?: (id<XZRefreshingDelegate>)_scrollView.delegate;
}

@end
