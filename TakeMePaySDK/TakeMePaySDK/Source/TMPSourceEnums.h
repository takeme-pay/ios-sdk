//
//  TMPSourceEnums.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TMPSourceType) {
    TMPSourceTypeUnknown = 0,
    TMPSourceTypeWeChatPay,
    TMPSourceTypeAlipay
    // apple pay, line pay, xxx pay...
};

typedef NS_ENUM(NSInteger, TMPSourceStatus) {
    TMPSourceStatusUnknown = 0,
    TMPSourceStatusPending,
    TMPSourceStatusChargeable,
    TMPSourceStatusConsumed,
    TMPSourceStatusFailed
};

typedef NS_ENUM(NSInteger, TMPSourceFlow) {
    TMPSourceFlowUnknown = 0,
    TMPSourceFlowRedirect
};

typedef NS_ENUM(NSInteger, TMPSourceRedirectStatus) {
    TMPSourceRedirectStatusUnknown = 0,
    TMPSourceRedirectStatusPending,
    TMPSourceRedirectStatusSucceeded,
    TMPSourceRedirectStatusFailed
};
