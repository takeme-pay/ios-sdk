//
//  TMPPayment+TMPClosureSupport.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/5/14.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPayment+TMPClosureSupport.h"
#import <objc/runtime.h>

@implementation TMPPayment (TMPClosureSupport)

#define IMPLEMENT_CLOSURE(methodSignature, value) \
- (instancetype)methodSignature { \
objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_COPY_NONATOMIC); \
return self; \
}

IMPLEMENT_CLOSURE(setWillCreateSourceByUsingBlock:(void (^)(TMPPayment * _Nonnull, TMPSourceParams * _Nonnull))willCreateSourceByUsing, willCreateSourceByUsing);

IMPLEMENT_CLOSURE(setDidCreateSourceBlock:(void (^)(TMPPayment * _Nonnull, TMPSource * _Nullable, NSError * _Nullable, NSDictionary * _Nullable))didCreateSource, didCreateSource);

IMPLEMENT_CLOSURE(setDidReceivedSourceTypesBlock:(void (^)(TMPPayment * _Nonnull, NSArray<NSString *> * _Nullable, NSString * _Nullable, NSError * _Nullable, NSDictionary * _Nullable))didReceivedSourceTypes, didReceivedSourceTypes);

IMPLEMENT_CLOSURE(setDidFinishAuthorizationBlock:(void (^)(TMPPayment * _Nonnull, TMPPaymentAuthorizationState, NSError * _Nullable, NSDictionary * _Nullable))didFinishAuthorization, didFinishAuthorization);

IMPLEMENT_CLOSURE(setDidPolledSourceBlock:(void (^)(TMPPayment * _Nonnull, TMPSource * _Nullable, TMPPaymentPollingResultState, NSError * _Nullable, NSDictionary * _Nullable))didPolledSource, didPolledSource);

IMPLEMENT_CLOSURE(setWillFinishWithStateBlock:(void (^)(TMPPayment * _Nonnull, TMPPaymentResultState, NSError * _Nullable, NSDictionary * _Nullable))willFinishWithState, willFinishWithState);

IMPLEMENT_CLOSURE(setDidFinishWithStateBlock:(void (^)(TMPPayment * _Nonnull, TMPPaymentResultState, NSError * _Nullable, NSDictionary * _Nullable))didFinishWithState, didFinishWithState);

@end
