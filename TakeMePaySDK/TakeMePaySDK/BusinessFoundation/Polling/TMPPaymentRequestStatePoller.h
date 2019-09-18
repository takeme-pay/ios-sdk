//
//  TMPPaymentRequestStatePoller.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPSourceEnums.h"
#import "TMPPaymentEnums.h"

@class TMPPaymentServiceClient, TMPSource;

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentRequestStatePoller : NSObject

@property (nonatomic, weak, readonly) TMPPaymentServiceClient *underlyingClient;
@property (nonatomic, strong, readonly) NSString *clientSecret;
@property (nonatomic, strong, readonly) NSString *sourceId;
@property (nonatomic, assign, readonly) NSTimeInterval timeout;

- (instancetype)initWithClient:(TMPPaymentServiceClient *)client clientSecret:(NSString *)clientSecret sourceId:(NSString *)sourceId timeout:(NSTimeInterval)timeout completion:(void(^)(TMPPaymentPollingResultState state, NSError *))completion;

- (void)stopPolling;

@end

NS_ASSUME_NONNULL_END
