//
//  TMEndpointAPIManager.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TMEndpointAPIManager.h"
#import "TMEndpointRequestOperation.h"
#import "TMNetworkingOperationManager.h"
#import "TMNetworkConfiguration.h"

@interface TMEndpointAPIManager ()

@property (nonatomic, strong) TMNetworkConfiguration *configuration;

@end

@implementation TMEndpointAPIManager

- (instancetype)initWithConfiguration:(TMNetworkConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (TMEndpointRequestOperation *)startEndpointRequest:(id<TMEndpointAPIRequest>)request completion:(TWEndpointResponseBlock)completion {
    if (![request conformsToProtocol:@protocol(TMEndpointAPIRequest)]) {
        return nil;
    }
    
    TMEndpointRequestOperation *operation = [[TMEndpointRequestOperation alloc] initWithConfiguration:self.configuration endpointRequest:request completion:completion];
    
    [TMEndpointAPIManager startOperation:operation];
    
    return operation;
}

#pragma mark - private

+ (void)startOperation:(TMEndpointRequestOperation *)operation {
    if (!operation) {
        return;
    }
    
    [TMNetworkingOperationManager.sharedManager addOperation:operation purpose:TMNetworkingEndpointRequestPurpose];
}

@end
