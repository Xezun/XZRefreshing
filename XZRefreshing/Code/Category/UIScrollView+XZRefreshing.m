//
//  UIScrollView+XZRefreshing.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "UIScrollView+XZRefreshing.h"
#import "XZRefreshingManager.h"
#import "XZRefreshingStyle1View.h"
#import "XZRefreshingStyle2View.h"
#import <objc/runtime.h>

NSTimeInterval const XZRefreshingAnimationDuration = 0.35;
CGFloat        const XZRefreshingViewHeight        = 50.0;

@implementation UIScrollView (XZRefreshing)

- (XZRefreshingView *)xz_headerRefreshingView {
    return self.xz_refreshingManager.headerRefreshingView;
}

- (void)xz_setHeaderRefreshingView:(XZRefreshingView *)dxm_headerRefreshingView {
    self.xz_refreshingManager.headerRefreshingView = dxm_headerRefreshingView;
}

- (XZRefreshingView *)xz_headerRefreshingViewIfNeeded {
    return self.xz_refreshingManagerIfLoaded.headerRefreshingViewIfLoaded;
}

- (XZRefreshingView *)xz_footerRefreshingView {
    return self.xz_refreshingManager.footerRefreshingView;
}

- (void)xz_setFooterRefreshingView:(XZRefreshingView *)dxm_footerRefreshingView {
    self.xz_refreshingManager.footerRefreshingView = dxm_footerRefreshingView;
}

- (XZRefreshingView *)xz_footerRefreshingViewIfNeeded {
    return self.xz_refreshingManagerIfLoaded.footerRefreshingViewIfLoaded;
}

- (void)xz_setNeedsLayoutRefreshingViews {
    [self.xz_refreshingManagerIfLoaded setNeedsLayoutRefreshingViews];
}

- (void)xz_layoutRefreshingViewsIfNeeded {
    [self.xz_refreshingManagerIfLoaded layoutRefreshingViewsIfNeeded];
}

@end



