//
//  TMPPaymentEnums.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#ifndef TMPPaymentEnums_h
#define TMPPaymentEnums_h

typedef NS_ENUM(NSInteger, TMPPaymentResultState) {
    TMPPaymentResultStateUnknown = 0,
    TMPPaymentResultStateIdle,
    TMPPaymentResultStateInProgress,
    TMPPaymentResultStateSuccess,
    TMPPaymentResultStateFailure,
    TMPPaymentResultStateCanceled,
    TMPPaymentResultStatePossibleSuccess    // authorization is successful, but polling failed, caused by timeout or other reasons, should notify developer/user not to pay again, it's an ambiguous state of success
};

typedef NS_ENUM(NSInteger, TMPPaymentAuthorizationState) {
    TMPPaymentAuthorizationStateUnknown = 0,
    TMPPaymentAuthorizationStateSuccess,
    TMPPaymentAuthorizationStateFailure,
    TMPPaymentAuthorizationStateCanceled
};

typedef NS_ENUM(NSInteger, TMPPaymentPollingResultState) {
    TMPPaymentPollingResultStateUnknown = 0,
    TMPPaymentPollingResultStateSuccess,
    TMPPaymentPollingResultStateFailure,
    TMPPaymentPollingResultStateInProgress,
    TMPPaymentPollingResultStateTimeout
};

#endif /* TMPPaymentEnums_h */
