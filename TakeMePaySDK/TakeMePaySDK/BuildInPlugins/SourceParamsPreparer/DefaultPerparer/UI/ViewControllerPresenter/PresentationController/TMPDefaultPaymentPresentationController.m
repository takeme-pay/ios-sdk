//
//  TMPDefaultPaymentPresentationController.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/2.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPDefaultPaymentPresentationController.h"
#import "TMPPaymentDefaultUICheckoutCounterViewController.h"

@interface TMPDefaultPaymentPresentationController ()

@property (nonatomic, strong) id<UIViewControllerTransitionCoordinator> transitionCoordinator;
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation TMPDefaultPaymentPresentationController

#pragma mark - override

- (void)presentationTransitionWillBegin {
    self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.dimmingView.backgroundColor = UIColor.blackColor;
    
    self.contentView = self.containerView;
    [self.contentView addSubview:self.presentingViewController.view];
    [self.contentView addSubview:self.dimmingView];
    [self.contentView addSubview:self.presentedView];
    
    self.dimmingView.alpha = 0;
    self.transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0.7;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    self.transitionCoordinator = self.presentingViewController.transitionCoordinator;
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
    
    [UIApplication.sharedApplication.keyWindow addSubview:self.presentingViewController.view];
}

- (BOOL)shouldRemovePresentersView {
    return NO;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return self.containerView.bounds;
}

@end
