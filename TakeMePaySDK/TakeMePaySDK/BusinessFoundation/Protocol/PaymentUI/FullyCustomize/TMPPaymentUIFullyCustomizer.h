//
//  TMPPaymentUIFullyCustomizer.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPPaymentUICheckoutCounterRenderer.h"
#import "TMPPaymentUIPaymentMethodRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TMPPaymentUIFullyCustomizer <NSObject>

@required
- (UIViewController<TMPPaymentUICheckoutCounterRenderer> *)homeViewController;  // entry view controller
- (UIViewController<TMPPaymentUIPaymentMethodRenderer> *)paymentMethodViewController;   // payment method

@end

NS_ASSUME_NONNULL_END
