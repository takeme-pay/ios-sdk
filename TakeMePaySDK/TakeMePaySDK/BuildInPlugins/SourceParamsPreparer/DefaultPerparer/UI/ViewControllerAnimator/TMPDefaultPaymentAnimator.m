//
//  TMPDefaultPaymentAnimator.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/4.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPDefaultPaymentAnimator.h"

@interface TMPDefaultPaymentAnimator ()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UINavigationControllerOperation operation;

@end

@implementation TMPDefaultPaymentAnimator

- (instancetype)initWithDuration:(NSTimeInterval)duration operation:(UINavigationControllerOperation)operation {
    if (self = [super init]) {
        _duration = duration;
        _operation = operation;
    }
    
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    
    CGRect startFrame = CGRectZero;
    CGRect endFrame = CGRectZero;
    
    if (self.operation == UINavigationControllerOperationPush) {
        startFrame = CGRectMake(container.bounds.size.width, 0, container.bounds.size.width, container.bounds.size.height);
        endFrame = CGRectMake(-fromView.bounds.size.width, 0, fromView.bounds.size.width, fromView.bounds.size.height);
    } else if (self.operation == UINavigationControllerOperationPop) {
        startFrame = CGRectMake(-container.bounds.size.width, 0, container.bounds.size.width, container.bounds.size.height);
        endFrame = CGRectMake(fromView.bounds.size.width, 0, fromView.bounds.size.width, fromView.bounds.size.height);
    }
    
    toView.frame = startFrame;
    
    [container addSubview:toView];
    
    [UIView animateWithDuration:self.duration animations:^{
        toView.frame = finalFrame;
        fromView.frame = endFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

@end
