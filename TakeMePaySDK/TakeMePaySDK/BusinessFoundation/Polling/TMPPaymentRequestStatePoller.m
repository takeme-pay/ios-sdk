//
//  TMPPaymentRequestStatePoller.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentRequestStatePoller.h"
#import "TMPSourcePoller.h"
#import "TMPSource.h"
#import "NSError+TMPErrorGenerator.h"

static NSTimeInterval const DEFAULT_POLLING_TIMEOUT = 60;

@interface TMPPaymentRequestStatePoller ()

@property (nonatomic, strong) TMPSourcePoller *sourcePoller;
@property (nonatomic, copy) void(^stateCompletion)(TMPPaymentPollingResultState, NSError *);

@end

@implementation TMPPaymentRequestStatePoller

- (instancetype)initWithClient:(TMPPaymentServiceClient *)client clientSecret:(NSString *)clientSecret sourceId:(NSString *)sourceId timeout:(NSTimeInterval)timeout completion:(void (^)(TMPPaymentPollingResultState, NSError *))completion {
    if (self = [super init]) {
        _stateCompletion = completion;
        _sourcePoller = [[TMPSourcePoller alloc] initWithClient:client clientSecret:clientSecret sourceId:sourceId timeout:isnan(timeout) ? DEFAULT_POLLING_TIMEOUT : timeout completion:[self completionForSourcePoller]];
    }
    return self;
}

- (void)stopPolling {
    [self.sourcePoller stopPolling];
    self.sourcePoller = nil;
}

#pragma mark - private

- (void(^)(TMPSource *, NSError *))completionForSourcePoller {
    __weak typeof(self) weakSelf = self;
    return ^(TMPSource *source, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            if ((error || !source) && strongSelf.stateCompletion) {
                if ([error isEqual:[NSError tmp_sourcePollingTimeoutError]]) {
                    strongSelf.stateCompletion(TMPPaymentPollingResultStateTimeout, error);
                } else {
                    strongSelf.stateCompletion(TMPPaymentPollingResultStateFailure, error);
                }
                
                return;
            }
            
            NSDictionary<NSNumber *, NSNumber *> *const stateMapper = @{
                                                                        @(TMPSourceStatusUnknown) : @(TMPPaymentPollingResultStateFailure),
                                                                        @(TMPSourceStatusPending) : @(TMPPaymentPollingResultStateInProgress),
                                                                        @(TMPSourceStatusChargeable) : @(TMPPaymentPollingResultStateInProgress),
                                                                        @(TMPSourceStatusConsumed) : @(TMPPaymentPollingResultStateSuccess),
                                                                        @(TMPSourceStatusFailed) : @(TMPPaymentPollingResultStateFailure)
                                                                        };
            
            NSDictionary<NSNumber *, NSError *> *const errorMapper = @{
                                                                       @(TMPSourceStatusFailed) : [NSError tmp_pollingSourceStatusError:@"failed" source:source]
                                                                       };
            
            strongSelf.stateCompletion([stateMapper[@(source.status)] integerValue], errorMapper[@(source.status)]);
        }
    };
}

@end
