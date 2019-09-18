//
//  TMPPaymentUIPaymentMethodLogicResponder.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPPaymentMethod;
@protocol TMPPaymentUIPaymentMethodRenderer;

NS_ASSUME_NONNULL_BEGIN

/**
 The delegate methods for PaymentMethod renderer, for handling user actions.
 */
@protocol TMPPaymentUIPaymentMethodLogicResponder <NSObject>

@required

/**
 Invoked when user did select one payment method.

 @param paymentMethodView Current PaymentMethod renderer.
 @param paymentMethodItem Selected payment method item by user.
 @param index The index of selected payment method in the list, might be useless.
 */
- (void)paymentMethodView:(UIViewController<TMPPaymentUIPaymentMethodRenderer> *)paymentMethodView didSelect:(TMPPaymentMethod *)paymentMethodItem atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
