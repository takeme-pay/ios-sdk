//
//  TMPPaymentAuthorizable.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPPaymentEnums.h"

@class TMPPayment, TMPSource;

NS_ASSUME_NONNULL_BEGIN

@protocol TMPPaymentAuthorizable <NSObject>

@required

// the method should be called on the main queue
- (void)requestPaymentAuthorization:(TMPPayment *)payment source:(TMPSource *)source userInfo:(nullable NSDictionary *)userInfo completion:(void(^)(TMPPaymentAuthorizationState authorizationState, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
