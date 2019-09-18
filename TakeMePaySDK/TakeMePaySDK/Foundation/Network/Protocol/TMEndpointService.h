//
//  TMEndpointService.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMEndpointAPIRequest.h"
#import "TMNetworkConfiguration.h"

@protocol TMEndpointService <NSObject>

@property (nonatomic, strong, readonly) id<TMEndpointAPIRequest> request;

- (instancetype)initWithConfiguration:(TMNetworkConfiguration *)configuration;  // for injection

// for requesting API endpoint type resources
- (void)request:(id<TMEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *urlResponse, id decodedObject, NSError *error))completion;

// cancel a request if needed
- (void)cancel;

@end
