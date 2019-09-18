//
//  TMPPaymentUICheckoutCounterLogicResponder.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TMPPaymentUICheckoutCounterRenderer, TMPPaymentUIPaymentMethodRenderer;

NS_ASSUME_NONNULL_BEGIN

/**
 The delegate methods for CheckoutCounter renderer, for handling user actions.
 */
@protocol TMPPaymentUICheckoutCounterLogicResponder <NSObject>

@required

/**
 Invoked when user pressed pay button.

 @param checkoutCounter Current CheckoutCounter renderer
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)checkoutCounter:(UIViewController<TMPPaymentUICheckoutCounterRenderer> *)checkoutCounter payPressed:(NSDictionary * __nullable)userInfo;

/**
 Invoked when CheckoutCounter renderer wants to be closed.

 @param checkoutCounter Current CheckoutCounter renderer.
 */
- (void)dismissCheckoutCounter:(UIViewController<TMPPaymentUICheckoutCounterRenderer> *)checkoutCounter;

@optional

/**
 Invoked when user wants to change payment method, marked as optional means that your CheckoutCounter renderer may can't change payment method at all.

 @param checkoutCounter Current CheckoutCounter renderer.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)checkoutCounter:(UIViewController<TMPPaymentUICheckoutCounterRenderer> *)checkoutCounter changePaymentMethodPressed:(NSDictionary * __nullable)userInfo;

@end

NS_ASSUME_NONNULL_END
