//
//  TMNetworkConfiguration.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TMNetworkConfiguration.h"
#import "TMNetworkDataJSONSerializer.h"
#import "TMNetworkDataFormURLEncodedSerializer.h"

@implementation TMNetworkConfiguration

- (Class<TMNetworkDataSerializer>)serializer:(TMNetworkDataSerializerType)serializerType {
    switch (serializerType) {
        case TMNetworkDataSerializerJSONType:
            return TMNetworkDataJSONSerializer.class;
        case TMNetworkDataSerializerFormURLEncodedType:
            return TMNetworkDataFormURLEncodedSerializer.class;
        default:
            return TMNetworkDataJSONSerializer.class;
    }
}

@end
