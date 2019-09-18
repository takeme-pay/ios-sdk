//
//  TMPTestPaymentMethod.m
//  TakeMePaySDKTests
//
//  Created by tianren.zhu on 2019/5/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPTestPaymentMethod.h"

@implementation TMPTestPaymentMethod

TMP_PAYMENT_METHOD(@"TestPaymentMethod")

- (NSString *)paymentMethodId {
    return @"TestPaymentMethod";
}

- (BOOL)available {
    return YES;
}

- (NSString *)unavailableReason {
    return @"";
}

- (TMPSourceType)tmp_sourceType {
    return TMPSourceTypeUnknown;
}

- (TMPSourceFlow)tmp_sourceFlow {
    return TMPSourceFlowRedirect;
}

- (void)requestPaymentAuthorization:(TMPPayment *)payment source:(TMPSource *)source userInfo:(NSDictionary *)userInfo completion:(void (^)(TMPPaymentAuthorizationState, NSError * _Nullable))completion {
    if (completion) {
        if (userInfo[@"authStatus"]) {
            completion([userInfo[@"authStatus"] integerValue], [[NSError alloc] init]);
        } else {
            completion(TMPPaymentAuthorizationStateSuccess, nil);
        }
    }
}

@end
