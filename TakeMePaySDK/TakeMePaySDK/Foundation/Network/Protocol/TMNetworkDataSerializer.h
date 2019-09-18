//
//  TMNetworkDataSerializer.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TMNetworkDataSerializerType) {
    TMNetworkDataSerializerJSONType,
    TMNetworkDataSerializerFormURLEncodedType
};

@protocol TMNetworkDataSerializer <NSObject>

+ (NSData *)serializeDictionary:(NSDictionary *)dictionary error:(NSError **)error;
+ (id)deserializeData:(NSData *)data error:(NSError **)error;
+ (NSString *)contentType;

@end
