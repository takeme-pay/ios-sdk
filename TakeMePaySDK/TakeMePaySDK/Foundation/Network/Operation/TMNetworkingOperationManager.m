//
//  TMNetworkingOperationManager.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TMNetworkingOperationManager.h"

@interface TMNetworkingOperationManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSOperationQueue *> *queuesAssociateWithPurpose;

@end

@implementation TMNetworkingOperationManager

+ (instancetype)sharedManager {
    static TMNetworkingOperationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMNetworkingOperationManager alloc] init];
        instance.queuesAssociateWithPurpose = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

- (void)addOperation:(NSOperation *)operation purpose:(TMNetworkingOperationPurpose)purpose {
    if (!operation) {
        return;
    }
    
    @synchronized (self.queuesAssociateWithPurpose) {
        if (!self.queuesAssociateWithPurpose[@(purpose)]) {
            self.queuesAssociateWithPurpose[@(purpose)] = generateQueueWith(purpose);
        }
        
        [self.queuesAssociateWithPurpose[@(purpose)] addOperation:operation];
    }
}

#pragma mark - private

static NSOperationQueue *generateQueueWith(TMNetworkingOperationPurpose purpose) {
    switch (purpose) {
        case TMNetworkingEndpointRequestPurpose:
        case TMNetworkingImageDownloadingPurpose:
            return queueWithDefaultSetting();
        default:
            return queueWithDefaultSetting();
    }
}

static inline NSOperationQueue *queueWithDefaultSetting() {
    NSOperationQueue *result = [[NSOperationQueue alloc] init];
    result.maxConcurrentOperationCount = 5;
    return result;
}

@end
