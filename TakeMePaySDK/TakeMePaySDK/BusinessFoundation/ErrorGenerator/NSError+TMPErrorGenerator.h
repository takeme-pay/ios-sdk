//
//  NSError+TMPErrorGenerator.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/28.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPSource, TMPSourceParams;

NS_ASSUME_NONNULL_BEGIN

@interface NSError (TMPErrorGenerator)

+ (instancetype)tmp_sourcePollingTimeoutError;
+ (instancetype)tmp_sourcePollerInitializationError;

+ (instancetype)tmp_requestSourceFromRemoteErrorBecauseOfParams;
+ (instancetype)tmp_requestSourceFromRemoteError:(NSError *)networkError;
+ (instancetype)tmp_createSourceObjectFromDictionaryFailedError:(NSDictionary *)dictionary;

+ (instancetype)tmp_requestSourceTypesFromRemoteErrorBecauseOfParams;
+ (instancetype)tmp_requestSourceTypesFromRemoteError:(NSError *)networkError;
+ (instancetype)tmp_requestSourceTypesFromRemoteParsedError;

+ (instancetype)tmp_normalizeRedirectTypeFromSourceError:(TMPSource *)source;
+ (instancetype)tmp_openUrlErrorWhenRedirect:(NSURL *)url source:(TMPSource *)source channel:(NSString *)channel;
+ (instancetype)tmp_pollingSourceStatusError:(NSString *)status source:(TMPSource *)source;

+ (instancetype)tmp_genericPaymentErrorFromDictionaryError:(NSDictionary *)dictionary;

+ (instancetype)tmp_authorizationErrorFromDictionaryError:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
