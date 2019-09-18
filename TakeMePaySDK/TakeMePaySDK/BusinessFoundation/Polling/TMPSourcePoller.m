//
//  TMPSourcePoller.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPSourcePoller.h"
#import <UIKit/UIKit.h>
#import "TMPSource.h"
#import "TMPPaymentServiceClient.h"
#import "TMUtils.h"
#import "NSError+TMPErrorGenerator.h"
#import "TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport.h"

static NSTimeInterval const DEFAULT_POLL_INTERVAL = 1.5;
static NSTimeInterval const MAX_POLL_INTERVAL = 24;
static NSTimeInterval const MAX_TIMEOUT = 60 * 1;
static NSTimeInterval const MAX_RETRIES = 5;

@interface TMPSourcePoller ()

@property (nonatomic, weak, readwrite) TMPPaymentServiceClient *underlyingClient;
@property (nonatomic, strong, readwrite) NSString *clientSecret;
@property (nonatomic, strong, readwrite) NSString *sourceId;
@property (nonatomic, assign, readwrite) NSTimeInterval timeout;
@property (nonatomic, copy) void(^completion)(TMPSource *, NSError *);

@property (nonatomic, strong) TMPSource *latestReceivedSource;  // same sourceId but status may be different

@property (nonatomic, assign) NSTimeInterval pollInterval;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timeoutTimer;

@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) NSUInteger requestCount;

@property (nonatomic, assign) BOOL pollingPaused;
@property (nonatomic, assign) BOOL pollingStopped;

@end

@implementation TMPSourcePoller {
    dispatch_queue_t _workQueue;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithClient:(TMPPaymentServiceClient *)client clientSecret:(NSString *)clientSecret sourceId:(NSString *)sourceId timeout:(NSTimeInterval)timeout completion:(void(^)(TMPSource *, NSError *))completion {
    if (self = [super init]) {
        _underlyingClient = client;
        _clientSecret = clientSecret;
        _sourceId = sourceId;
        _timeout = timeout;
        _completion = completion;
        
        // validate args
        if (!initArgsIsValid(client, clientSecret, sourceId, timeout, completion)) {
            if (completion) {
                completion(nil, [NSError tmp_sourcePollerInitializationError]);
            }
        }
        
        _pollInterval = DEFAULT_POLL_INTERVAL;
        _retryCount = 0;
        _requestCount = 0;
        
        _pollingPaused = NO;
        _pollingStopped = NO;
        
        _workQueue = dispatch_queue_create("com.takemepay.polling", DISPATCH_QUEUE_SERIAL);
        
        [self registerNotifications];
        [self startPolling];
    }
    return self;
}

#pragma mark - public

- (void)stopPolling {
    dispatch_async(_workQueue, ^{
        self.pollingStopped = YES;
        [self.timer invalidate];
        self.timer = nil;
        
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    });
}

#pragma mark - private

- (void)startPolling {
    _startDate = NSDate.date;
    
    [self pollAfter:0];
    
    // timeout timer
    __weak typeof(self) weakSelf = self;
    dispatch_async(_workQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer * _Nonnull timer) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if ([strongSelf isTimeout]) {
                    [strongSelf stopPolling];
                    if (strongSelf.completion) {
                        strongSelf.completion(nil, [NSError tmp_sourcePollingTimeoutError]);
                    }
                    
                    return;
                }
            }];
            [NSRunLoop.currentRunLoop run];
        }
    });
}

- (void)registerNotifications {
    static NSString *const RESTART_POLLING_SEL_STRING = @"restartPolling:";
    static NSString *const PAUSE_POLLING_SEL_STRING = @"pausePolling:";
    
    NSDictionary *mapper = @{
                             UIApplicationDidBecomeActiveNotification : RESTART_POLLING_SEL_STRING,
                             UIApplicationWillEnterForegroundNotification : RESTART_POLLING_SEL_STRING,
                             UIApplicationWillResignActiveNotification : PAUSE_POLLING_SEL_STRING,
                             UIApplicationDidEnterBackgroundNotification : PAUSE_POLLING_SEL_STRING
                             };
    
    NSNotificationCenter *defaultCenter = NSNotificationCenter.defaultCenter;
    for (NSString *notificationName in mapper.allKeys) {
        [defaultCenter addObserver:self selector:NSSelectorFromString(mapper[notificationName]) name:notificationName object:nil];
    }
}

- (void)pollAfter:(NSTimeInterval)interval {
    dispatch_async(_workQueue, ^{
        BOOL isTimeout = [self isTimeout];
        
        if (isTimeout) {
            [self stopPolling];
            
            if (self.completion) {
                self.completion(nil, [NSError tmp_sourcePollingTimeoutError]);
            }
            
            return;
        }
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.pollInterval repeats:NO block:self.timerBlock];
        [NSRunLoop.currentRunLoop run];
    });
}

- (void(^)(NSTimer *))timerBlock {
    __weak typeof(self) weakSelf = self;
    return ^(NSTimer *timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(strongSelf->_workQueue, ^{
                [strongSelf.timer invalidate];
                strongSelf.timer = nil;
            });
            
            if ([strongSelf isTimeout]) {
                [strongSelf stopPolling];
                if (strongSelf.completion) {
                    strongSelf.completion(nil, [NSError tmp_sourcePollingTimeoutError]);
                }
                return;
            }
            
            // needs urlResponse, so use TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport directly
            [strongSelf.underlyingClient retrieveSource:({
                TMPSourceParams *params = [[TMPSourceParams alloc] init];
                params.sourceId = strongSelf.sourceId;
                params.clientSecret = strongSelf.clientSecret;
                params;
            }) completion:^(TMPSource *source, NSURLResponse *urlResponse, NSError *error) {
                if ([urlResponse isKindOfClass:NSHTTPURLResponse.class]) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
                    
                    NSUInteger status = httpResponse.statusCode;
                    
                    if (status >= 400 && status < 500) {
                        [strongSelf stopPolling];
                        
                        if (strongSelf.completion) {
                            strongSelf.completion(nil, error);
                        }
                    } else if (status == 200) {
                        strongSelf.pollInterval = DEFAULT_POLL_INTERVAL;
                        strongSelf.retryCount = 0;
                        strongSelf.latestReceivedSource = source;
                        if (shouldContinuePolling(source)) {
                            [strongSelf pollAfter:strongSelf.pollInterval];
                        } else {
                            [strongSelf stopPolling];
                            // success
                            strongSelf.completion(source, nil);
                            strongSelf.completion = nil;
                        }
                    } else {
                        strongSelf.pollInterval = MIN(strongSelf.pollInterval * 2, MAX_POLL_INTERVAL);
                        strongSelf.retryCount += 1;
                        [strongSelf pollAfter:strongSelf.pollInterval];
                    }
                } else {
                    if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
                        strongSelf.retryCount += 1;
                        [strongSelf pollAfter:strongSelf.pollInterval];
                    } else {
                        if (error.code != kCFURLErrorCancelled) {
                            [strongSelf stopPolling];
                            if (strongSelf.completion) {
                                strongSelf.completion(source, error);
                            }
                        }
                        [strongSelf stopPolling];
                    }
                }
            }];
        }
    };
}

#pragma mark - notifications selectors

- (void)restartPolling:(NSNotification *)notification {
    if (self.pollingStopped) {
        return;
    }
    
    self.pollingPaused = NO;
    [self pollAfter:0];
}

- (void)pausePolling:(NSNotification *)notification {
    self.pollingPaused = YES;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - utils

static inline BOOL initArgsIsValid(TMPPaymentServiceClient *client, NSString *clientSecret, NSString *sourceId, NSTimeInterval timeout, void(^completion)(TMPSource *, NSError *)) {
    return
    [client isKindOfClass:TMPPaymentServiceClient.class] &&
    ![TMUtils stringIsEmpty:sourceId] &&
    [@(timeout) compare:@(0)] != NSOrderedAscending &&
    completion;
}

- (BOOL)isTimeout {
    NSTimeInterval totalTimeInterval = [NSDate.date timeIntervalSinceDate:_startDate];
    
    return (_requestCount >= 0 && (totalTimeInterval >= MIN(_timeout, MAX_TIMEOUT) || _retryCount >= MAX_RETRIES));
}

static inline BOOL shouldContinuePolling(TMPSource *source) {
    if (![source isKindOfClass:TMPSource.class]) {
        return NO;
    }
    
    return
    source.status == TMPSourceStatusPending ||
    source.status == TMPSourceStatusChargeable;
}

@end
