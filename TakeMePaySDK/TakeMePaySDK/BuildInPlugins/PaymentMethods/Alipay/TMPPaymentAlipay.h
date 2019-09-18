//
//  TMPPaymentAlipay.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/1.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>
#import "TMPURLListener.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))

@interface TMPPaymentAlipay : TMPPaymentMethod <TMPURLListener>

@end

NS_ASSUME_NONNULL_END
