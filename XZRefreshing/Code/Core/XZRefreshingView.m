//
//  XZRefreshingView.m
//  XZRefreshing
//
//  Created by Xezun on 2023/8/10.
//

#import "XZRefreshingView.h"
#import "XZRefreshingManager.h"
#import <objc/runtime.h>


@interface XZRefreshingView () {
    XZRefreshingManager * __weak _refreshingManager;
}

@end


@implementation XZRefreshingView

@synthesize animationHeight = _animationHeight;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _adjustment = XZRefreshingAdjustmentAutomatic;
    }
    return self;
}

- (UIScrollView *)scrollView {
    return [_refreshingManager scrollView];
}

- (void)setAdjustment:(XZRefreshingAdjustment)adjustment {
    if (_adjustment != adjustment) {
        _adjustment = adjustment;
        [_refreshingManager setNeedsLayoutRefreshingViews];
    }
}

- (BOOL)isAnimating {
    return [_refreshingManager isRefreshingViewAnimating:self];
}

- (void)setAnimating:(BOOL)animating {
    [self beginAnimating:NO completion:nil];
}

- (void)setOffset:(CGFloat)offset {
    if (_offset != offset) {
        _offset = offset;
        [_refreshingManager setNeedsLayoutRefreshingViews];
    }
}

- (void)beginAnimating:(BOOL)animated completion:(nullable void (^)(BOOL))completion {
    [_refreshingManager refreshingView:self beginAnimating:animated completion:completion];
}

- (void)beginAnimating {
    [self beginAnimating:YES completion:nil];
}

- (void)endAnimating:(BOOL)animated completion:(nullable void (^)(BOOL))completion {
    [_refreshingManager refreshingView:self endAnimating:animated completion:completion];
}

- (void)endAnimating {
    [self endAnimating:YES completion:nil];
}

- (CGFloat)animationHeight {
    if (_animationHeight > 0) {
        return _animationHeight;
    }
    return self.bounds.size.height;
}

- (void)setAnimationHeight:(CGFloat)animationHeight {
    if (_animationHeight != animationHeight) {
        _animationHeight = animationHeight;
        [_refreshingManager setNeedsLayoutRefreshingViews];
    }
}

- (void)scrollView:(UIScrollView *)scrollView didScrollDistance:(CGFloat)distance {
    
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    return (distance >= self.animationHeight);
}

- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated {
    // Configure the refreshing animation.
}

- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated {
    
}

- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated {
    
}

@end

@implementation XZRefreshingView (XZRefreshingManager)

- (XZRefreshingManager *)refreshingManager {
    return _refreshingManager;
}

- (void)setRefreshingManager:(XZRefreshingManager *)refreshingManager {
    _refreshingManager = refreshingManager;
}

@end
