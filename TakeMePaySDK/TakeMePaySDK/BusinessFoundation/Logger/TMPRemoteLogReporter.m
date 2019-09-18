//
//  TMPRemoteLogReporter.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPRemoteLogReporter.h"
#import <UIKit/UIKit.h>
#import "TMPConfiguration.h"
#import "TMNetworkConfiguration.h"
#import "TMEndpointAPIRequest.h"
#import "TMEndpointAPIManager.h"
#import "TMPPaymentServiceClient+TMPPrivate.h"
#import "TMLogService.h"
#import "TMPRemoteLogPersistenceStrategy.h"
#import "TMPRemoteLogPersistenceItemCountsStrategy.h"
#import "NSMutableDictionary+TMFExtension.h"
#import "NSArray+TMFExtension.h"
#import "TMPRemoteLogInfo+TMPPrivate.h"

@implementation TMPRemoteLogInfo

#pragma mark - TMDictionaryConvertible

+ (instancetype)convertFromDictionary:(nonnull NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    TMPRemoteLogInfo *result = [[TMPRemoteLogInfo alloc] init];
    
    result.level = dict[@"level"];
    result.message = dict[@"message"];
    result.metadata = dict[@"metadata"];
    result.timestamp = dict[@"timestamp"];
    
    result.tmp_associatedFileName = dict[@"associatedFileName"];
    
    return result;
}

+ (NSDictionary *)convertToDictionary:(TMPRemoteLogInfo *)obj {
    if (![obj isKindOfClass:self]) {
        return nil;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result tmf_safeSetObject:obj.level forKey:@"level"];
    [result tmf_safeSetObject:obj.message forKey:@"message"];
    [result tmf_safeSetObject:obj.metadata forKey:@"metadata"];
    [result tmf_safeSetObject:obj.timestamp forKey:@"timestamp"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        _level = [aDecoder decodeObjectForKey:@"level"];
        _message = [aDecoder decodeObjectForKey:@"message"];
        _metadata = [aDecoder decodeObjectForKey:@"metadata"];
        _timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        
        self.tmp_associatedFileName = [aDecoder decodeObjectForKey:@"associatedFileName"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.level forKey:@"level"];
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.metadata forKey:@"metadata"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    
    [aCoder encodeObject:self.tmp_associatedFileName forKey:@"associatedFileName"];
}

@end

@interface TMPRemoteLogParams : NSObject <TMEndpointAPIRequest>

@property (nonatomic, strong) NSArray<TMPRemoteLogInfo *> *logs;

@end

@implementation TMPRemoteLogParams

- (NSString *)endpoint {
    return @"";
}

- (NSString *)httpMethod {
    return @"";
}

- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSMutableArray<NSDictionary *> *logs = [[NSMutableArray alloc] init];
    
    for (TMPRemoteLogInfo *logInfo in self.logs) {
        if ([logInfo isKindOfClass:TMPRemoteLogInfo.class]) {
            NSDictionary *logInfoDict = [TMPRemoteLogInfo convertToDictionary:logInfo];
            if ([logInfoDict isKindOfClass:NSDictionary.class]) {
                [logs addObject:logInfoDict];
            }
        }
    }
    
    params[@"logs"] = logs.copy;
    
    return params.copy;
}

- (NSDictionary *)additionalHeaders {
    return @{};
}

- (TMNetworkDataSerializerType)serializerType {
    return TMNetworkDataSerializerJSONType;
}

- (TMNetworkDataSerializerType)deserializerType {
    return TMNetworkDataSerializerJSONType;
}

@end

@interface TMPRemoteLogReporter () <TMPRemoteLogPersistenceDelegate>

@property (nonatomic, readonly) TMEndpointAPIManager *endpointAPIManager;
@property (nonatomic, strong) TMPPaymentServiceClient *client;
@property (nonatomic, strong) id<TMPRemoteLogPersistenceStrategy> persistenceStrategy;

@end

@implementation TMPRemoteLogReporter

- (instancetype)init {
    if (self = [super init]) {
        _client = [[TMPPaymentServiceClient alloc] initWithConfiguration:TMPConfiguration.defaultConfiguration];
        
        _persistenceStrategy = [[TMPRemoteLogPersistenceItemCountsStrategy alloc] initWithBuilder:^(TMPRemoteLogPersistenceItemCountsStrategyBuilder * _Nonnull builder) {            
            builder.delegate = self;            
        }];
    }
    
    return self;
}

#pragma mark - TMPRemoteLogPersistenceDelegate

- (void)persistItemFinished:(id<TMPRemoteLogPersistenceStrategy>)strategy isTouchWaterMark:(BOOL)touchwaterMark {
    if (touchwaterMark) {
        // 1. retrieve persistence data from strategy
        NSArray<TMPRemoteLogInfo *> *persistedData = strategy.persistedData;
        
        // 2. send them
        if ([persistedData isKindOfClass:NSArray.class] && persistedData.count > 0) {
            [self sendToRemote:remoteLogParamsFrom(persistedData) completion:^(BOOL success) {
                
                // 3. purge them from strategy if successfully send to remote server, or else, wait for next time `persistItemFinished:isTouchWaterMark:`
                if (success) {
                    [strategy purgeData:persistedData];
                }
            }];
        }
    }
}

- (void)sendDirectlyIfInEmergencyCase:(NSArray<TMPRemoteLogInfo *> *)pendings completion:(void (^)(__unused BOOL success))completion {
    [self sendToRemote:remoteLogParamsFrom(pendings) completion:nil];
}

#pragma mark - TMLogLevelObserver

- (void)consumeObservedInformation:(TMLogInformation *)information {
    if (![information isKindOfClass:TMLogInformation.class]) {
        return;
    }
    
    [self.persistenceStrategy receivedData:({
        TMPRemoteLogInfo *params = [[TMPRemoteLogInfo alloc] init];
        
        params.level = information.logLevelLiteral;
        params.message = information.message;
        params.metadata = information.extraInfo;
        params.timestamp = @(information.timestamp);
        
        params;
    })];
}

#pragma mark - private

- (void)sendToRemote:(TMPRemoteLogParams *)params completion:(void(^)(BOOL success))completion {
    if (![params isKindOfClass:TMPRemoteLogParams.class] || ![params.logs isKindOfClass:NSArray.class] || params.logs.count <= 0) {
        return;
    }
    
    [self.endpointAPIManager startEndpointRequest:params completion:[self requestCompletionThen:completion]];
}

- (void(^)(NSURLResponse *, id, NSError *))requestCompletionThen:(void(^)(BOOL success))completion {
    return ^(NSURLResponse *urlResponse, id decodedObject, NSError *error) {
        if (completion) {
            completion(!error || !(((NSHTTPURLResponse *)urlResponse).statusCode < 200 || ((NSHTTPURLResponse *)urlResponse).statusCode >= 300));
        }
    };
}

#pragma mark - getter

- (TMEndpointAPIManager *)endpointAPIManager {
    return _client.tmp_endpointApiManager;
}

#pragma mark - util

static inline TMPRemoteLogParams *remoteLogParamsFrom(NSArray<TMPRemoteLogInfo *> *logs) {
    return ({
        TMPRemoteLogParams *params = [[TMPRemoteLogParams alloc] init];
        params.logs = logs;
        params;
    });
}

@end
