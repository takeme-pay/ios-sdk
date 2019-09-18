//
//  TMPSourceParams+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/9.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPSourceParams+TMPPrivate.h"
#import "TMPSourceTypeConstants.h"
#import <objc/runtime.h>

@implementation TMPSourceParams (TMPPrivate)

- (void)setRedirectReturnUrl:(NSString *)redirectReturnUrl {
    if (redirectReturnUrl) {
        objc_setAssociatedObject(self, @selector(redirectReturnUrl), redirectReturnUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)redirectReturnUrl {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)_rawType {
    return @{
             @(TMPSourceTypeUnknown) : TMPSourceTypeUnknownString,
             @(TMPSourceTypeWeChatPay) : TMPSourceTypeWeChatPayString,
             @(TMPSourceTypeAlipay) : TMPSourceTypeAlipayString
             // ...
             }[@(self.type)];
}

- (NSString *)_rawFlow {
    return @{
             @(TMPSourceFlowUnknown) : @"unknown",
             @(TMPSourceFlowRedirect) : @"redirect"
             // ...
             }[@(self.flow)];
}

+ (TMPSourceType)typeFromRaw:(NSString *)type {
    return [@{
              TMPSourceTypeUnknownString : @(TMPSourceTypeUnknown),
              TMPSourceTypeWeChatPayString : @(TMPSourceTypeWeChatPay),
              TMPSourceTypeAlipayString : @(TMPSourceTypeAlipay)
              // ...
              }[type] integerValue];
}

+ (TMPSourceFlow)flowFromRaw:(NSString *)flow {
    return [@{
              @"unknown" : @(TMPSourceFlowUnknown),
              @"redirect" : @(TMPSourceFlowRedirect)
              // ...
              }[flow] integerValue];
}

@end
