//
//  TMPPaymentMethodRegisterSupport.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/22.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TMP_PAYMENT_METHOD(SourceType) \
FOUNDATION_EXPORT void TMPRegisterPaymentMethod(Class class, NSString *sourceType); \
+ (void)load { TMPRegisterPaymentMethod(self, SourceType); }

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentMethodRegisterSupport : NSObject

+ (NSDictionary<NSString *, Class> *)registeredPaymentMethods;

@end

NS_ASSUME_NONNULL_END
