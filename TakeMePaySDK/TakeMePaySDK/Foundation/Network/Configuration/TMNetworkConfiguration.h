//
//  TMNetworkConfiguration.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMNetworkDataSerializer.h"
#import "TMEndpointAPIRequest.h"

__attribute__((objc_subclassing_restricted))

@interface TMNetworkConfiguration : NSObject

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSDictionary *defaultHeaders;

- (Class<TMNetworkDataSerializer>)serializer:(TMNetworkDataSerializerType)serializerType;

@end
