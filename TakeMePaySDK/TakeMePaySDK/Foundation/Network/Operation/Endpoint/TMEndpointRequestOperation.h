//
//  TMNetworkOperation.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMEndpointAPIRequest.h"

@class TMNetworkConfiguration;
@protocol TMEndpointService;

@interface TMEndpointRequestOperation : NSOperation

@property (nonatomic, strong, readonly) id<TMEndpointAPIRequest> request;

- (instancetype)initWithConfiguration:(TMNetworkConfiguration *)configuration endpointRequest:(id<TMEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *urlResponse, id decodedObject, NSError *error))completion;

#pragma mark - unavailable

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end
