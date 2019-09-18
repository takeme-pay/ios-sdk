//
//  TMPPaymentMethodRegisterSupport.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/22.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentMethodRegisterSupport.h"

@implementation TMPPaymentMethodRegisterSupport

static NSMutableDictionary<NSString *, Class> *PaymentMethods;
+ (NSDictionary<NSString *, Class> *)registeredPaymentMethods {
    return PaymentMethods.copy;
}

@end

void TMPRegisterPaymentMethod(Class class, NSString *sourceType) {
    if (!class) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PaymentMethods = [[NSMutableDictionary alloc] init];
    });
    
    @synchronized (PaymentMethods) {
        [PaymentMethods setObject:class forKey:sourceType];
    }
}
