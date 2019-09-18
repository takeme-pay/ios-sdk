//
//  TMPTestSourceParamsPreparer.m
//  TakeMePaySDKTests
//
//  Created by tianren.zhu on 2019/5/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPTestSourceParamsPreparer.h"
#import "TMPTestPaymentMethod.h"

@interface TMPTestSourceParamsPreparer ()

@property (nonatomic, strong) TMPPaymentMethod *selectedPaymentMethod;
@property (nonatomic, copy) void(^completion)(TMPPaymentResultState, NSError * __nullable);

@end

@implementation TMPTestSourceParamsPreparer

@synthesize payment = _payment;
@synthesize latestError = _latestError;

- (TMPPaymentMethod *)paymentMethod {
    return self.selectedPaymentMethod;
}

- (void)prepareSourceParams:(TMPSourceParams *)rawSourceParams availableSourceTypes:(NSArray<TMPPaymentMethod *> *)sourceTypes userInfo:(NSDictionary *)userInfo decoratedSourceParams:(void (^)(TMPSourceParams * _Nonnull))decoratedSourceParamsBlock completion:(void (^)(TMPPaymentResultState, NSError * _Nullable))completion {
    self.completion = completion;
    self.selectedPaymentMethod = sourceTypes.firstObject;
    
    if (decoratedSourceParamsBlock) {
        decoratedSourceParamsBlock(rawSourceParams);
    }
}

- (void)payment:(TMPPayment *)payment didCreateSource:(TMPSource *)source error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error && self.completion) {
        self.completion(TMPPaymentResultStateFailure, error);
    }
}

- (void)payment:(TMPPayment *)payment didFinishAuthorization:(TMPPaymentAuthorizationState)state error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error && self.completion) {
        self.completion(TMPPaymentResultStateFailure, error);
    }
}

- (void)payment:(TMPPayment *)payment didPolledSource:(TMPSource *)source state:(TMPPaymentPollingResultState)state error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error) {
        self.completion(TMPPaymentResultStateFailure, error);
    } else if (self.completion) {
        self.completion(TMPPaymentResultStateSuccess, nil);
    }
}

@end
