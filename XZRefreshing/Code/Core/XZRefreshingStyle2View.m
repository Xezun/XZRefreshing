//
//  XZRefreshingStyle2View.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "XZRefreshingStyle2View.h"
#import "UIScrollView+XZRefreshing.h"
#import "XZRefreshingDefines.h"

#define kAnimationDuration 1.5
#define kWidth             20.0

@implementation XZRefreshingStyle2View {
    UIView *_dotsView;
    CAShapeLayer *_dot0Layer;
    CAShapeLayer *_dot1Layer;
    CAShapeLayer *_dot2Layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self XZRefreshingDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZRefreshingDidInitialize];
    }
    return self;
}

- (void)XZRefreshingDidInitialize {
    _colors = @[
        [UIColor colorWithWhite:0.50 alpha:1.0],
        [UIColor colorWithWhite:0.70 alpha:1.0],
        [UIColor colorWithWhite:0.90 alpha:1.0]
    ];
    
    CGRect const bounds = self.bounds;
    CGFloat const x = CGRectGetMidX(bounds) - kWidth * 1.5;
    CGFloat const y = CGRectGetMidY(bounds) - kWidth * 0.5;
    
    _dotsView = [[UIView alloc] initWithFrame:CGRectMake(x, y, kWidth * 3.0, kWidth)];
    _dotsView.userInteractionEnabled = NO;
    _dotsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_dotsView];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kWidth * 0.5, kWidth * 0.5) radius:3.0 startAngle:-M_PI endAngle:+M_PI clockwise:YES];
    [path closePath];
    
    _dot0Layer = [[CAShapeLayer alloc] init];
    _dot0Layer.frame = CGRectMake(0, 0, kWidth, kWidth);
    _dot0Layer.path  = path.CGPath;
    [_dotsView.layer addSublayer:_dot0Layer];
    
    _dot2Layer = [[CAShapeLayer alloc] init];
    _dot2Layer.frame  = CGRectMake(2.0 * kWidth, 0, kWidth, kWidth);
    _dot2Layer.path  = path.CGPath;
    [_dotsView.layer addSublayer:_dot2Layer];
    
    _dot1Layer = [[CAShapeLayer alloc] init];
    _dot1Layer.frame = CGRectMake(kWidth, 0, kWidth, kWidth);
    _dot1Layer.path  = path.CGPath;
    [_dotsView.layer addSublayer:_dot1Layer];
    
    // 初始状态
    _dot0Layer.fillColor = _colors[1].CGColor;
    _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0);
    _dot1Layer.fillColor = _colors[1].CGColor;
    _dot1Layer.transform = CATransform3DMakeScale(0, 0, 1.0);
    _dot2Layer.fillColor = _colors[1].CGColor;
    _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0);
}

- (void)setColors:(NSArray<UIColor *> *)colors {
    NSParameterAssert(colors.count >= 3);
    _colors = colors.copy;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _dot0Layer.fillColor = _colors[1].CGColor;
    _dot1Layer.fillColor = _colors[1].CGColor;
    _dot2Layer.fillColor = _colors[1].CGColor;
    [CATransaction commit];
}

- (void)scrollView:(UIScrollView *)scrollView didScrollDistance:(CGFloat)distance {
    XZLog(@"%s: %f", __PRETTY_FUNCTION__, distance);
    CGFloat const value = distance / self.animationHeight;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (value < 0.5) {
        // 等待进场
        _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0);
        _dot1Layer.transform = CATransform3DMakeScale(0, 0, 1.0);
        _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0);
    } else if (value < 1.0) {
        // 变大进场
        CGFloat const scale = 2.0 * ((value - 0.5) * 2.0);
        _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), scale, scale, 1.0);
        _dot1Layer.transform = CATransform3DMakeScale(scale, scale, 1.0);
        _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), scale, scale, 1.0);
    } else if (value < 1.5) {
        // 蓄力刷新
        CGFloat const trans = 1.0 - (value - 1.0) * 2.0;
        CGFloat const scale = 1.0 + 1.0 * MAX(0, (trans * 3.0 - 2.0));
        _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+kWidth * trans, 0, 0), scale, scale, 1.0);
        _dot1Layer.transform = CATransform3DMakeScale(scale, scale, 1.0);
        _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-kWidth * trans, 0, 0), scale, scale, 1.0);
    } else {
        // 等待刷新
        _dot0Layer.transform = CATransform3DIdentity;
        _dot1Layer.transform = CATransform3DIdentity;
        _dot2Layer.transform = CATransform3DIdentity;
    }
    [CATransaction commit];
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    XZLog(@"%s: %f", __PRETTY_FUNCTION__, distance);
    return distance >= self.animationHeight * 1.5;
}

- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    _dot0Layer.transform = CATransform3DIdentity;
    _dot1Layer.transform = CATransform3DIdentity;
    _dot2Layer.transform = CATransform3DIdentity;
    
    CFTimeInterval beginTime = 0;
    if (animated) {
        beginTime = [_dot1Layer convertTime:CACurrentMediaTime() toLayer:nil] + XZRefreshingAnimationDuration;
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshingAnimationDuration;
        animation.removedOnCompletion = YES;
        
        animation.values = @[
            @(CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        [_dot0Layer addAnimation:animation forKey:@"entering"];
        animation.values = @[
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        [_dot1Layer addAnimation:animation forKey:@"entering"];
        animation.values = @[
            @(CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        [_dot2Layer addAnimation:animation forKey:@"entering"];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    animation.beginTime   = beginTime;
    animation.duration    = kAnimationDuration;
    animation.repeatCount = FLT_MAX;
    animation.removedOnCompletion = NO;
    
    animation.values = @[
        (__bridge id)_colors[0].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[2].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[0].CGColor,
    ];
    [_dot0Layer addAnimation:animation forKey:@"refreshing"];
    
    animation.values = @[
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[0].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[2].CGColor,
        (__bridge id)_colors[1].CGColor,
    ];
    [_dot1Layer addAnimation:animation forKey:@"refreshing"];
    
    animation.values = @[
        (__bridge id)_colors[2].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[0].CGColor,
        (__bridge id)_colors[1].CGColor,
        (__bridge id)_colors[2].CGColor,
    ];
    [_dot2Layer addAnimation:animation forKey:@"refreshing"];
}

- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    [_dot0Layer removeAnimationForKey:@"refreshing"];
    [_dot1Layer removeAnimationForKey:@"refreshing"];
    [_dot2Layer removeAnimationForKey:@"refreshing"];
    
    if (animated) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshingAnimationDuration;
        animation.removedOnCompletion = YES;
        
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0)),
        ];
        [_dot0Layer addAnimation:animation forKey:@"recovering"];
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DMakeScale(0, 0, 1.0)),
        ];
        [_dot1Layer addAnimation:animation forKey:@"recovering"];
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0)),
            @(CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0)),
        ];
        [_dot2Layer addAnimation:animation forKey:@"recovering"];
    }
}

- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _dot0Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(+kWidth, 0, 0), 0, 0, 1.0);
    _dot1Layer.transform = CATransform3DMakeScale(0, 0, 1.0);
    _dot2Layer.transform = CATransform3DScale(CATransform3DMakeTranslation(-kWidth, 0, 0), 0, 0, 1.0);
    [CATransaction commit];
}

@end
