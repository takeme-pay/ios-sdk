//
//  TMPSourcePoller.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPPaymentServiceClient, TMPSource;

NS_ASSUME_NONNULL_BEGIN

@interface TMPSourcePoller : NSObject

@property (nonatomic, weak, readonly) TMPPaymentServiceClient *underlyingClient;
@property (nonatomic, strong, readonly) NSString *clientSecret;
@property (nonatomic, strong, readonly) NSString *sourceId;
@property (nonatomic, assign, readonly) NSTimeInterval timeout;

- (instancetype)initWithClient:(TMPPaymentServiceClient *)client clientSecret:(NSString *)clientSecret sourceId:(NSString *)sourceId timeout:(NSTimeInterval)timeout completion:(void(^)(TMPSource *source, NSError *error))completion;

- (void)stopPolling;

@end

NS_ASSUME_NONNULL_END
