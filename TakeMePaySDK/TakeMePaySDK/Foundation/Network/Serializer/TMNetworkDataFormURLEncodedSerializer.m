//
//  TMNetworkDataFormURLEncodedSerializer.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TMNetworkDataFormURLEncodedSerializer.h"

@implementation TMNetworkDataFormURLEncodedSerializer

+ (NSData *)serializeDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
    if (![dictionary isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    NSInteger index = 0;
    for (NSString *key in dictionary.allKeys) {
        if (![key isKindOfClass:NSString.class] || ![dictionary[key] isKindOfClass:NSString.class]) {
            continue;
        }
        
        [mutableString appendFormat:@"%@=%@", key, dictionary[key]];
        if (index++ != dictionary.allKeys.count - 1) {
            [mutableString appendString:@"&"];
        }                
    }
    
    return [mutableString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)deserializeData:(NSData *)data error:(NSError *__autoreleasing *)error {
    NSAssert(NO, @"unimplement");
    return nil;
}

+ (NSString *)contentType {
    return @"application/x-www-form-urlencoded";
}

@end
