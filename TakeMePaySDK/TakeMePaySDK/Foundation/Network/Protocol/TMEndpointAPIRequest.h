//
//  TMEndpointAPIRequest.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNetworkDataSerializer.h"

@protocol TMEndpointAPIRequest <NSObject>

@required
@property (nonatomic, strong, readonly) NSString *endpoint;
@property (nonatomic, strong, readonly) NSString *httpMethod;
@property (nonatomic, strong, readonly) NSDictionary *params;
@property (nonatomic, strong, readonly) NSDictionary *additionalHeaders;
@property (nonatomic, assign, readonly) TMNetworkDataSerializerType serializerType;
@property (nonatomic, assign, readonly) TMNetworkDataSerializerType deserializerType;

@end

@protocol TMEndpointAPIRequestInjectDefaultHeaders <NSObject>

@property (nonatomic, assign, readonly) BOOL injectDefaultHeaders;

@end
