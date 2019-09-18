//
//  TMPPaymentAlipay.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/1.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentAlipay.h"
#import <TakeMePaySDK/TMPSourceTypeConstants.h>
#import <TakeMePaySDK/TMPPaymentMethodRegisterSupport.h>
#import <TakeMePaySDK/NSError+TMPErrorGenerator.h>
#import <TakeMePaySDK/TMUtils.h>
#import <TakeMePaySDK/TakeMePay.h>
#import <TakeMePaySDK/TMLogService.h>
#import "TMPPaymentAuthViaWebRedirect.h"

@interface TMPPaymentAlipay ()

@property (nonatomic, strong) TMPPaymentAuthViaWebRedirect *webRedirect;

@end

@implementation TMPPaymentAlipay

TMP_PAYMENT_METHOD(TMPSourceTypeAlipayString)

- (NSString *)paymentMethodId {
    return TMPSourceTypeAlipayString;
}

- (TMPSourceType)tmp_sourceType {
    return TMPSourceTypeAlipay;
}

- (TMPSourceFlow)tmp_sourceFlow {
    return TMPSourceFlowRedirect;
}

#pragma mark - TMPPaymentAuthorizable

- (void)requestPaymentAuthorization:(TMPPayment *)payment source:(TMPSource *)source userInfo:(NSDictionary *)userInfo completion:(void (^)(TMPPaymentAuthorizationState, NSError * _Nullable))completion {
    [self.webRedirect requestPaymentAuthorization:payment source:source userInfo:userInfo completion:completion];
}

#pragma mark - TMPPaymentSourceParamsProcessable

- (void)payment:(TMPPayment *)payment processSourceParams:(TMPSourceParams *)params userInfo:(nullable NSDictionary *)userInfo completion:(void (^)(TMPSourceParams * _Nullable))completion {
    [super payment:payment processSourceParams:params userInfo:userInfo completion:^(TMPSourceParams * _Nullable processedSourceParams) {
        [self.webRedirect payment:payment processSourceParams:processedSourceParams userInfo:userInfo completion:completion];
    }];
}

#pragma mark - TMPURLListener

- (BOOL)shouldHandleWithUrl:(nonnull NSURL *)url {
    return [self.webRedirect shouldHandleWithUrl:url];
}

#pragma mark - getter

- (TMPPaymentAuthViaWebRedirect *)webRedirect {
    if (!_webRedirect) {
        _webRedirect = [[TMPPaymentAuthViaWebRedirect alloc] init];
    }
    return _webRedirect;
}

@end
