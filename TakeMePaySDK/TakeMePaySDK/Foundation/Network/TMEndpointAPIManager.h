//
//  TMEndpointAPIManager.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMEndpointAPIRequest.h"

@class TMEndpointRequestOperation, TMNetworkConfiguration;

typedef void(^TWEndpointResponseBlock)(NSURLResponse *urlResponse, id decodedObject, NSError *error);

@interface TMEndpointAPIManager : NSObject

- (instancetype)initWithConfiguration:(TMNetworkConfiguration *)configuration;

// shouldn't invoke this method directly, using methods in category is a better approach.
- (TMEndpointRequestOperation *)startEndpointRequest:(id<TMEndpointAPIRequest>)request completion:(TWEndpointResponseBlock)completion;

@end
