//
//  TMPDefaultPaymentVCPresenter.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/2.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMPDefaultPaymentVCPresenter.h"
#import "TMPDefaultPaymentPresentationController.h"
#import "TMPPaymentUICheckoutCounterRenderer.h"
#import "TMPPaymentUIPaymentMethodRenderer.h"
#import "TMPDefaultPaymentAnimator.h"
#import "TMUtils.h"
#import "TMPPayment.h"
#import <SafariServices/SafariServices.h>

@interface TMPDefaultPaymentVCPresenter () <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation TMPDefaultPaymentVCPresenter

#pragma mark - TMPDefaultPaymentVCPresenter

- (void)payment:(TMPPayment *)payment showPaymentViewController:(UIViewController *)viewController completion:(nullable void (^)(void))completion {
    [TMUtils executeOnMainQueue:^{
        [self topVC:^(UIViewController *topVC) {
            if ([viewController conformsToProtocol:@protocol(TMPPaymentUICheckoutCounterRenderer)]) {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                navigationController.navigationBarHidden = YES;
                
                navigationController.delegate = self;
                navigationController.transitioningDelegate = self;
                navigationController.modalPresentationStyle = UIModalPresentationCustom;
                
                self.navigationController = navigationController;
                
                [topVC presentViewController:navigationController animated:YES completion:completion];
                return;
            }
            
            if ([viewController conformsToProtocol:@protocol(TMPPaymentUIPaymentMethodRenderer)] && self.navigationController) {
                [self.navigationController pushViewController:viewController animated:YES];
                if (completion) {
                    completion();
                }
                return;
            }
            
            if ([viewController isKindOfClass:SFSafariViewController.class]) {
                [topVC presentViewController:viewController animated:YES completion:completion];
                return;
            }
        }];
    } sync:NO];
}

- (void)payment:(TMPPayment *)payment dismissPaymentViewController:(UIViewController *)viewControler completion:(nullable void (^)(void))completion {
    [TMUtils executeOnMainQueue:^{
        if ([viewControler conformsToProtocol:@protocol(TMPPaymentUICheckoutCounterRenderer)]) {
            NSAssert(self.navigationController.viewControllers.count == 1 && self.navigationController.viewControllers[0] == viewControler, @"when dismiss checkout counter renderer, it should be the only one vc of navigation controller");
            
            [self.navigationController dismissViewControllerAnimated:YES completion:completion];
            return;
        }
        
        if ([viewControler isKindOfClass:SFSafariViewController.class]) {
            [viewControler dismissViewControllerAnimated:YES completion:completion];
            return;
        }
        
        if (self.navigationController.viewControllers.lastObject == viewControler) {
            [self.navigationController popViewControllerAnimated:YES];
            if (completion) {
                completion();
            }
        }
    } sync:NO];
}

#pragma mark - private

- (void)topVC:(void(^)(UIViewController *topVC))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        completion([self topVCOf:UIApplication.sharedApplication.keyWindow.rootViewController]);
    });
}

- (nullable UIViewController *)topVCOf:(UIViewController *)viewController {
    if (!viewController.presentedViewController) {
        return viewController;
    }
    
    if ([viewController.presentedViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)viewController.presentedViewController;
        UIViewController *lastViewController = navigationController.viewControllers.lastObject;
        return [self topVCOf:lastViewController];
    }
    
    UIViewController *presentedVC = viewController.presentedViewController;
    return [self topVCOf:presentedVC];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    TMPDefaultPaymentPresentationController *presentationController = [[TMPDefaultPaymentPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return presentationController;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return [[TMPDefaultPaymentAnimator alloc] initWithDuration:0.4f operation:operation];
}

@end
