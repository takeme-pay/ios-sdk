//
//  TMPPaymentVCPresenter.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/2.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TMPPayment;

NS_ASSUME_NONNULL_BEGIN

/**
 The TMPPaymentVCPresenter handles the view controllers transition, you can customize your own view controller transition behaviour for your renderer.
 */
@protocol TMPPaymentVCPresenter <NSObject>

@required

/**
 Handles all view controller showing behaviours in TakeMe Pay SDK scope.

 @param payment Current associated TMPPayment instance.
 @param viewController The ready to show view controller.
 @param completion Completion
 */
- (void)payment:(TMPPayment *)payment showPaymentViewController:(UIViewController *)viewController completion:(nullable void(^)(void))completion;

/**
 Handles all view controller dismissing behaviours in TakeMe Pay SDK scope.

 @param payment Current associated TMPPayment instance.
 @param viewControler The ready to dismiss view controller.
 @param completion Completion
 */
- (void)payment:(TMPPayment *)payment dismissPaymentViewController:(UIViewController *)viewControler completion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
