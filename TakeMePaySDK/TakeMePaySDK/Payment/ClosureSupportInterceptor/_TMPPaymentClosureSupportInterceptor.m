//
//  _TMPPaymentClosureSupportInterceptor.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/5/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "_TMPPaymentClosureSupportInterceptor.h"
#import <objc/runtime.h>
#import "TMPPayment+TMPClosureSupport.h"

@implementation _TMPPaymentClosureSupportInterceptor

#pragma mark - TMPPaymentDelegate

- (void)payment:(TMPPayment *)payment willCreateSourceByUsing:(TMPSourceParams *)params {
    void(^block)(TMPPayment *, TMPSourceParams *) = objc_getAssociatedObject(payment, @selector(setWillCreateSourceByUsingBlock:));
    
    if (block) {
        block(payment, params);
    }
}

- (void)payment:(TMPPayment *)payment didCreateSource:(TMPSource *)source error:(NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    void(^block)(TMPPayment *, TMPSource * __nullable, NSError * __nullable, NSDictionary * __nullable) = objc_getAssociatedObject(payment, @selector(setDidCreateSourceBlock:));
    
    if (block) {
        block(payment, source, error, userInfo);
    }
}

- (void)payment:(TMPPayment *)payment didReceivedSourceTypes:(NSArray<NSString *> *)sourceTypes selectedSourceType:(NSString *)selectedSourceType error:(NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    void(^block)(TMPPayment *, NSArray<NSString *> * __nullable, NSString * __nullable, NSError * __nullable, NSDictionary * __nullable) = objc_getAssociatedObject(payment, @selector(setDidReceivedSourceTypesBlock:));
    
    if (block) {
        block(payment, sourceTypes, selectedSourceType, error, userInfo);
    }
}

- (void)payment:(TMPPayment *)payment didFinishAuthorization:(TMPPaymentAuthorizationState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    void(^block)(TMPPayment *, TMPPaymentAuthorizationState state, NSError * __nullable, NSDictionary * __nullable) = objc_getAssociatedObject(payment, @selector(setDidFinishAuthorizationBlock:));
    
    if (block) {
        block(payment, state, error, userInfo);
    }
}

- (void)payment:(TMPPayment *)payment didPolledSource:(TMPSource * __nullable)source state:(TMPPaymentPollingResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    void(^block)(TMPPayment *, TMPSource *, TMPPaymentPollingResultState state, NSError * __nullable, NSDictionary * __nullable) = objc_getAssociatedObject(payment, @selector(setDidPolledSourceBlock:));
    
    if (block) {
        block(payment, source, state, error, userInfo);
    }
}

- (void)payment:(TMPPayment *)payment willFinishWithState:(TMPPaymentResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    void(^block)(TMPPayment *, TMPPaymentResultState state, NSError * __nullable, NSDictionary * __nullable) = objc_getAssociatedObject(payment, @selector(setWillFinishWithStateBlock:));
    
    if (block) {
        block(payment, state, error, userInfo);
    }
}

- (void)payment:(TMPPayment *)payment didFinishWithState:(TMPPaymentResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    void(^block)(TMPPayment *, TMPPaymentResultState state, NSError * __nullable, NSDictionary * __nullable) = objc_getAssociatedObject(payment, @selector(setDidFinishWithStateBlock:));
    
    if (block) {
        block(payment, state, error, userInfo);
    }
}

@end
