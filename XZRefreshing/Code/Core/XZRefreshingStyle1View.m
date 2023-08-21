//
//  XZRefreshingStyle1View.m
//  XZRefresh
//
//  Created by Xezun on 2019/10/12.
//  Copyright © 2019 Xezun. All rights reserved.
//

#import "XZRefreshingStyle1View.h"
#import "UIScrollView+XZRefreshing.h"
#import "XZRefreshingDefines.h"

#define kAnimationDuration  3.0
#define kTrackColor         [UIColor colorWithWhite:0.90 alpha:1.0]

@implementation XZRefreshingStyle1View {
    UIView *_view;
    CAShapeLayer *_trackLayer;
    CAShapeLayer *_shapeLayer;
}

@synthesize color = _color;
@synthesize trackColor = _trackColor;

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
    CGRect  const bounds = self.bounds;
    CGFloat const x = CGRectGetMidX(bounds) - 15.0;
    CGFloat const y = CGRectGetMidY(bounds) - 15.0;
    CGRect  const frame = CGRectMake(x, y, 30.0, 30.0);
    
    _view = [[UIView alloc] initWithFrame:frame];
    _view.userInteractionEnabled = NO;
    _view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_view];
    
    _trackLayer = [[CAShapeLayer alloc] init];
    _trackLayer.frame = CGRectMake(0, 0, 30, 30);
    _trackLayer.lineWidth = 3.0;
    _trackLayer.strokeColor = kTrackColor.CGColor;
    _trackLayer.fillColor   = UIColor.clearColor.CGColor;
    _trackLayer.strokeStart = 0;
    _trackLayer.strokeEnd   = 1.0;
    _trackLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(5.0, 5.0, 20.0, 20.0)].CGPath;
    [_view.layer addSublayer:_trackLayer];
    
    _shapeLayer = [[CAShapeLayer alloc] init];
    _shapeLayer.frame = CGRectMake(0, 0, 30, 30);
    _shapeLayer.lineWidth = 3.0;
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.strokeColor = self.tintColor.CGColor;
    _shapeLayer.fillColor   = UIColor.clearColor.CGColor;
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 1.0;
    _shapeLayer.repeatCount = FLT_MAX;
    _shapeLayer.autoreverses = YES;
    // _shapeLayer.duration = 4.0; // 设置了 duration 就不显示 ？？
    [_view.layer addSublayer:_shapeLayer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(15.0, 5.0)];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    [path addArcWithCenter:CGPointMake(15.0, 15.0) radius:10.0 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    _shapeLayer.path = path.CGPath;
    
    // 初始状态
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 1.0 / 16.0;
    _trackLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
    _shapeLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0);
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    if (_color == nil) {
        _shapeLayer.strokeColor = self.tintColor.CGColor;
    }
}

- (UIColor *)color {
    return _color ?: self.tintColor;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _shapeLayer.strokeColor = self.color.CGColor;
}

- (UIColor *)trackColor {
    return _trackColor ?: kTrackColor;
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    _trackLayer.strokeColor = self.trackColor.CGColor;
}

- (void)scrollView:(UIScrollView *)scrollView didScrollDistance:(CGFloat)distance {
    XZLog(@"%s: %f", __PRETTY_FUNCTION__, distance);
    CGFloat const value = distance / self.animationHeight;
    
    if (value <= 0.5) {
        // 等待进场
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 1.0 / 16.0;
        _trackLayer.transform   = CATransform3DMakeScale(0, 0, 1.0);
        _shapeLayer.transform   = CATransform3DMakeScale(0, 0, 1.0);
    } else if (value < 1.0) {
        // 变大进场
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 1.0 / 16.0; // 0.34 * (1.5 - value);
        _trackLayer.transform   = CATransform3DMakeScale((value - 0.5) * 2.0, (value - 0.5) * 2.0, 1.0);
        _shapeLayer.transform   = CATransform3DMakeScale((value - 0.5) * 2.0, (value - 0.5) * 2.0, 1.0);
    } else if (value < 1.5) {
        // 蓄力刷新
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = MIN(1.0 / 16.0 + (4.0 / 16.0 - 1.0 / 16.0) * (value - 1.0) * 2.0, (4.0 - 0.2) / 16.0);
        _trackLayer.transform   = CATransform3DIdentity;
        _shapeLayer.transform   = CATransform3DIdentity;
    } else {
        // 等待刷新
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 4.0 / 16.0;
        _trackLayer.transform   = CATransform3DIdentity;
        _shapeLayer.transform   = CATransform3DIdentity;
    }
}

- (BOOL)scrollView:(UIScrollView *)scrollView shouldBeginRefreshing:(CGFloat)distance {
    XZLog(@"%s: %f", __PRETTY_FUNCTION__, distance);
    return distance >= self.animationHeight * 1.5;
}

- (void)scrollView:(UIScrollView *)scrollView didBeginRefreshing:(BOOL)animated {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    // 直接动画时，没有 shouldBeginRefreshing 的过程。
    _trackLayer.transform = CATransform3DIdentity;
    _shapeLayer.transform = CATransform3DIdentity;
    
    CFTimeInterval beginTime = 0;
    if (animated) {
        beginTime = [_shapeLayer convertTime:CACurrentMediaTime() toLayer:nil] + XZRefreshingAnimationDuration;
        
        // 直接进场时，动画的距离与下拉时的动画距离并不相同，因此动画效果不同。
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd   = 4.0 / 16.0;
        [CATransaction commit];
        
        // 不知为何 transform 的隐式动画时长不受控制，所以用了 CAAnimation （iOS 16.2）
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.values = @[
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DMakeScale(0, 0, 1.0)),
            @(CATransform3DIdentity)
        ];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshingAnimationDuration;
        animation.removedOnCompletion = YES;
        [_trackLayer addAnimation:animation forKey:@"entering"];
        [_shapeLayer addAnimation:animation forKey:@"entering"];
    }
    
    CAKeyframeAnimation *an1 = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    an1.values = @[
        @(0/16.0), @(4.8/16.0), @(6.0/16.0), @(10.8/16.0), @(12.0/16.0),
    ];
    CAKeyframeAnimation *an2 = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    an2.values = @[
        @(4.0/16.0), @(5.0/16.0), @(9.8/16.0), @(11.0/16.0), @(15.8/16.0)
    ];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations  = @[an1, an2];
    group.beginTime   = beginTime;
    group.duration    = kAnimationDuration;
    group.repeatCount = FLT_MAX;
    group.removedOnCompletion = NO;
    [_shapeLayer addAnimation:group forKey:@"refreshing"];
}

- (void)scrollView:(UIScrollView *)scrollView willEndRefreshing:(BOOL)animated {
    XZLog(@"%s", __PRETTY_FUNCTION__);

    CGFloat const start = _shapeLayer.presentationLayer.strokeStart;
    CGFloat const end   = _shapeLayer.presentationLayer.strokeEnd;
    [_shapeLayer removeAnimationForKey:@"refreshing"];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _shapeLayer.strokeStart = start;
    _shapeLayer.strokeEnd   = end;
    [CATransaction commit];
    
    if (animated) {
        // 退场动画
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.values = @[
            @(CATransform3DIdentity),
            @(CATransform3DMakeScale(0.0, 0.0, 1.0)),
            @(CATransform3DMakeScale(0.0, 0.0, 1.0))
        ];
        animation.keyTimes = @[@(0), @(0.5), @(1.0)];
        animation.duration = XZRefreshingAnimationDuration;
        animation.removedOnCompletion = YES;
        [_trackLayer addAnimation:animation forKey:@"recovering.transform"];
        [_shapeLayer addAnimation:animation forKey:@"recovering.transform"];
    }
}

- (void)scrollView:(UIScrollView *)scrollView didEndRefreshing:(BOOL)animated {
    XZLog(@"%s", __PRETTY_FUNCTION__);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _shapeLayer.strokeStart = 0;
    _shapeLayer.strokeEnd   = 1.0 / 16.0;
    _trackLayer.transform   = CATransform3DMakeScale(0.0, 0.0, 1.0);
    _shapeLayer.transform   = CATransform3DMakeScale(0.0, 0.0, 1.0);
    [CATransaction commit];
}

@end
