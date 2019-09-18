//
//  TMPConfiguration.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPConfiguration.h"
#import "TakeMePay.h"
#import "TMPSDKConstants.h"
#import "TMUtils.h"

@interface TMPConfiguration ()

@property (nonatomic, strong, readwrite) NSString *publicKey;
@property (nonatomic, strong, readwrite) NSString *baseUrl;
@property (nonatomic, strong, readwrite) NSString *apiVersion;
@property (nonatomic, strong, readwrite) NSString *companyName;
@property (nonatomic, strong, readwrite) NSString *distributedUrlSchemeHost;

@end

@implementation TMPConfiguration

+ (instancetype)defaultConfiguration {
    static TMPConfiguration *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMPConfiguration alloc] initWithBuilder:^(TMPConfiguration * _Nonnull config) {
            // user defined
            config.publicKey = TakeMePay.publicKey;
            config.companyName = TakeMePay.companyName;
            config.distributedUrlSchemeHost = TakeMePay.distributedUrlSchemeHost;
            
            // defined by us
            config.baseUrl = TMP_CONFIG_BASE_URL;
            config.apiVersion = TMP_CONFIG_API_VERSION;
            
            NSAssert(![TMUtils stringIsEmpty:config.publicKey], @"Set public key before use");
            assert(![TMUtils stringIsEmpty:TMP_CONFIG_BASE_URL]);
            assert(![TMUtils stringIsEmpty:TMP_CONFIG_API_VERSION]);
        }];
    });
    return instance;
}

#pragma mark - private

// may public this method if needed
- (instancetype)initWithBuilder:(void (^)(TMPConfiguration * _Nonnull))builder {
    TMPConfiguration *config = [super init];
    if (config && builder) {
        builder(config);
    }
    return config;
}

@end
