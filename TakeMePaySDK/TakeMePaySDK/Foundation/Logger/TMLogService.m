//
//  TMLogService.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/8.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMLogService.h"
#import "TMLogLevelObserver.h"
#import "TMErrorConvertible.h"

static char *const TM_LOG_SERVICE_WORK_QUEUE_IDENTIFIER = "com.takemepay.sdk.logservice";

@interface TMLogService ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<TMLogLevelObserver>> *> *observers;
@property (nonatomic, assign) BOOL consumersRegisterLocked;

@end

@implementation TMLogService {
    dispatch_queue_t _receivedInformationQueue;
}

+ (instancetype)shared {
    static TMLogService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMLogService alloc] init];
        instance->_receivedInformationQueue = dispatch_queue_create(TM_LOG_SERVICE_WORK_QUEUE_IDENTIFIER, DISPATCH_QUEUE_CONCURRENT);
        
        instance.observers = [[NSMutableDictionary alloc] init];
        instance.observers[@(TMLogLevelDebug)] = [[NSMutableArray alloc] init];
        instance.observers[@(TMLogLevelInfo)] = [[NSMutableArray alloc] init];
        instance.observers[@(TMLogLevelWarn)] = [[NSMutableArray alloc] init];
        instance.observers[@(TMLogLevelError)] = [[NSMutableArray alloc] init];
        instance.observers[@(TMLogLevelFatal)] = [[NSMutableArray alloc] init];
    });
    return instance;
}

- (void)registerObserver:(id<TMLogLevelObserver>)observer onLevel:(TMLogLevel)level {
    if (_consumersRegisterLocked) {
        return;
    }
    
    if (![observer conformsToProtocol:@protocol(TMLogLevelObserver)]) {
        return;
    }
    
    NSDictionary<NSNumber *, NSArray<id<TMLogLevelObserver>> *> * observers = [self observersOnLevelOption:TMLogLevelAll];
    
    if ([observers isKindOfClass:NSDictionary.class]) {
        [observers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<id<TMLogLevelObserver>> * _Nonnull obj, BOOL * _Nonnull stop) {
            if ((key.integerValue & level) && [obj isKindOfClass:NSMutableArray.class]) {
                @synchronized (obj) {
                    [(NSMutableArray *)obj addObject:observer];
                }
            }
        }];
    }
}

- (void)setUpDone {
    @synchronized (self.observers) {
        self.consumersRegisterLocked = YES;
    }
}

- (void)receivedInformation:(TMLogInformation *)information {
    @synchronized (self.observers) {
        if (!information || !self.consumersRegisterLocked) {
            return;
        }
        
        dispatch_async(_receivedInformationQueue, ^{
            NSDictionary<NSNumber *, NSArray<id<TMLogLevelObserver>> *> *observers = [self observersOnLevelOption:information.logLevel];
            
            if (![observers isKindOfClass:NSDictionary.class]) {
                return;
            }
            
            [observers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<id<TMLogLevelObserver>> * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:NSArray.class]) {
                    [obj enumerateObjectsUsingBlock:^(id<TMLogLevelObserver>  _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([observer respondsToSelector:@selector(consumeObservedInformation:)]) {
                            [observer consumeObservedInformation:information.copy];
                        }
                    }];
                }
            }];
        });
    }
}

#pragma mark - private

- (NSArray<id<TMLogLevelObserver>> *)observersOnDebug {
    return self.observers[@(TMLogLevelDebug)];
}

- (NSArray<id<TMLogLevelObserver>> *)observersOnInfo {
    return self.observers[@(TMLogLevelInfo)];
}

- (NSArray<id<TMLogLevelObserver>> *)observersOnWarn {
    return self.observers[@(TMLogLevelWarn)];
}

- (NSArray<id<TMLogLevelObserver>> *)observersOnError {
    return self.observers[@(TMLogLevelError)];
}

- (NSArray<id<TMLogLevelObserver>> *)observersOnFatal {
    return self.observers[@(TMLogLevelFatal)];
}

#pragma mark - getter

- (NSDictionary<NSNumber *, NSArray<id<TMLogLevelObserver>> *> *)observersOnLevelOption:(TMLogLevel)level {
    NSMutableDictionary<NSNumber *, NSArray<id<TMLogLevelObserver>> *> *result = [[NSMutableDictionary alloc] init];
    
    if (level & TMLogLevelDebug) {
        result[@(TMLogLevelDebug)] = [self observersOnDebug];
    }
    
    if (level & TMLogLevelInfo) {
        result[@(TMLogLevelInfo)] = [self observersOnInfo];
    }
    
    if (level & TMLogLevelWarn) {
        result[@(TMLogLevelWarn)] = [self observersOnWarn];
    }
    
    if (level & TMLogLevelError) {
        result[@(TMLogLevelError)] = [self observersOnError];
    }
    
    if (level & TMLogLevelFatal) {
        result[@(TMLogLevelFatal)] = [self observersOnFatal];
    }
    
    return result.copy;
}

@end

@interface TMLogInformation ()

@property (nonatomic, assign, readwrite) NSTimeInterval timestamp;

@end

@implementation TMLogInformation

- (instancetype)init {
    if (self = [super init]) {
        _timestamp = NSDate.date.timeIntervalSince1970 * 1000;  // milliseconds
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    TMLogInformation *instance = [[self.class allocWithZone:zone] init];
    
    instance.message = self.message;
    instance.logLevel = self.logLevel;
    instance.extraInfo = self.extraInfo;
    instance.timestamp = self.timestamp;
    
    return instance;
}

@end

@implementation TMLogInformation (TMLogLevelLiteral)

- (NSString *)logLevelLiteral {
    return @{@(TMLogLevelInfo) : @"info",
             @(TMLogLevelDebug) : @"debug",
             @(TMLogLevelWarn) : @"warn",
             @(TMLogLevelError) : @"error",
             @(TMLogLevelFatal) : @"fatal"}[@(self.logLevel)];
}

@end
