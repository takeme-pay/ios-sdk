//
//  NSError+TMPErrorGenerator.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/28.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "NSError+TMPErrorGenerator.h"
#import "TMLocalizationUtils.h"
#import "TMPSource.h"
#import "TMPSourceParams+TMPPrivate.h"

static NSString *const TMPErrorDomain = @"com.takemepay.sdk";

typedef NS_ENUM(NSInteger, TMPErrorCode) {
    TMPSourcePollingErrorCode,
    TMPSourceErrorCode,
    TMPSourceTypesErrorCode,
    TMPPaymentErrorCode,
    TMPAuthorizationErrorCode
};

static NSString *const TMPSourcePollingError = @"SourcePollingError";
static NSString *const TMPSourceError = @"SourceError";
static NSString *const TMPPaymentError = @"PaymentError";
static NSString *const TMPAuthorizationError = @"AuthorizationError";

@implementation NSError (TMPErrorGenerator)

#pragma mark - payment error

+ (instancetype)tmp_genericPaymentErrorFromDictionaryError:(NSDictionary *)dictionary {
    if ([dictionary isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        [userInfo setObject:TMLocalizedString(@"Payment failed because of generic error, please check the details") ?: @"" forKey:NSLocalizedDescriptionKey];
        
        return [self errorWithDomain:TMPErrorDomain code:TMPPaymentErrorCode userInfo:userInfo.copy];
    }
    
    return [[NSError alloc] init];
}

#pragma mark - payment authorization

+ (instancetype)tmp_authorizationErrorFromDictionaryError:(NSDictionary *)dictionary {
    if ([dictionary isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        [userInfo setObject:TMLocalizedString(@"Authorization failed because of error, please check the details") ?: @"" forKey:NSLocalizedDescriptionKey];
        
        return [self errorWithDomain:TMPErrorDomain code:TMPAuthorizationErrorCode userInfo:userInfo.copy];
    }
    
    return [[NSError alloc] init];
}

#pragma mark - source polling error

+ (instancetype)tmp_sourcePollingTimeoutError {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourcePollingErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(@"Source polling timeout, stop polling")}];
}

+ (instancetype)tmp_sourcePollerInitializationError {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourcePollingErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(@"Source poller initialization failed")}];
}

#pragma mark - source error

+ (instancetype)tmp_requestSourceFromRemoteErrorBecauseOfParams {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourceErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(descriptionOfParamsCheck(@"source"))}];
}

+ (instancetype)tmp_requestSourceFromRemoteError:(NSError *)networkError {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourceErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(descriptionOfRequestFromRemote(@"source")),
                                                                                   @"originalError" : networkError.localizedDescription ?: NSNull.null}];
}

+ (instancetype)tmp_createSourceObjectFromDictionaryFailedError:(NSDictionary *)dictionary {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourceErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(descriptionOfCreateTMPModelObject(@"TMPSource", dictionary))}];
}

#pragma mark - source types error

+ (instancetype)tmp_requestSourceTypesFromRemoteErrorBecauseOfParams {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourceTypesErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(descriptionOfParamsCheck(@"source types"))}];
}

+ (instancetype)tmp_requestSourceTypesFromRemoteError:(NSError *)networkError {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourceTypesErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(descriptionOfRequestFromRemote(@"source types")),
                                                                                        @"originalError" : networkError.localizedDescription ?: NSNull.null}];
}

+ (instancetype)tmp_requestSourceTypesFromRemoteParsedError {
    return [self errorWithDomain:TMPErrorDomain code:TMPSourceTypesErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString(@"Can't get any valid payment method from remote")}];
}

#pragma mark - payment engine error (redirect)

+ (instancetype)tmp_normalizeRedirectTypeFromSourceError:(TMPSource *)source {
    return [self errorWithDomain:TMPErrorDomain code:TMPPaymentErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString([NSString stringWithFormat:@"Can't get correct redirect type from source id: %@", source.sourceId])}];
}

+ (instancetype)tmp_openUrlErrorWhenRedirect:(NSURL *)url source:(TMPSource *)source channel:(NSString *)channel {
    return [self errorWithDomain:TMPErrorDomain code:TMPPaymentErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString([NSString stringWithFormat:@"Open %@ url: %@ error, source id: %@", channel, url.absoluteString, source.sourceId])}];
}

+ (instancetype)tmp_pollingSourceStatusError:(NSString *)status source:(TMPSource *)source {
    return [self errorWithDomain:TMPErrorDomain code:TMPPaymentErrorCode userInfo:@{NSLocalizedDescriptionKey : TMLocalizedString([NSString stringWithFormat:@"Polling source: %@ status is: %@, payment failed", source.sourceId, status])}];
}

#pragma mark - utils

static inline NSString *descriptionOfParamsCheck(NSString *scenario) {
    return [NSString stringWithFormat:@"Params has wrong when requeting %@ object from remote", scenario];
}

static inline NSString *descriptionOfCreateTMPModelObject(NSString *scenario, NSDictionary *dictionary) {
    return [NSString stringWithFormat:@"Create %@ object from dictionary failed, please check the TMDictionaryConvertible protocol implementation of %@ class, dictionary is: %@", scenario, scenario, dictionary.description];
}

static inline NSString *descriptionOfRequestFromRemote(NSString *scenario) {
    return [NSString stringWithFormat:@"Request %@ from remote error, more detailed information please check `originalError` in userInfo property of NSError", scenario];
}

@end
