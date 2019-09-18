//
//  TMPPaymentClient.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient.h"
#import "TMPSource.h"
#import "TMEndpointAPIManager.h"
#import "TMNetworkConfiguration.h"
#import "TMDeviceInfo.h"

@interface TMPPaymentServiceClient ()

@property (nonatomic, strong) TMEndpointAPIManager *endpointAPIManager;
@property (nonatomic, strong, readwrite) TMPConfiguration *configuration;

@end

@implementation TMPPaymentServiceClient

- (instancetype)initWithConfiguration:(TMPConfiguration *)configuration {
    NSAssert(configuration, @"configuration can't be nil");
    if (self = [super init]) {
        _configuration = configuration;
        
        [self setUpEndpointManager];
    }
    return self;
}

#pragma mark - private

- (void)setUpEndpointManager {
    TMNetworkConfiguration *config = [[TMNetworkConfiguration alloc] init];
    
    config.baseUrl = _configuration.baseUrl;
    config.authToken = [NSString stringWithFormat:@"Bearer %@", _configuration.publicKey];    
    
    {
        NSMutableDictionary *defaultHeaders = [NSMutableDictionary dictionaryWithDictionary:config.defaultHeaders ?: @{}];
        
        NSMutableString *deviceInfo = [[NSMutableString alloc] init];
        [deviceInfo appendString:[NSString stringWithFormat:@"osVersion=%@", TMDeviceInfo.osVersion]];
        [deviceInfo appendString:[NSString stringWithFormat:@"&deviceType=%@", TMDeviceInfo.deviceType]];
        [deviceInfo appendString:[NSString stringWithFormat:@"&networkType=%@", TMDeviceInfo.networkType]];
        [deviceInfo appendString:[NSString stringWithFormat:@"&carrier=%@", TMDeviceInfo.carrier]];
        [deviceInfo appendString:[NSString stringWithFormat:@"&isJailbreak=%@", TMDeviceInfo.isJailbreak ? @"true" : @"false"]];
        
        [defaultHeaders setObject:deviceInfo.copy forKey:@"DeviceInfo"];
        
        NSMutableString *sdkInfo = [[NSMutableString alloc] init];
        [sdkInfo appendString:[NSString stringWithFormat:@"sdkVersion=%@", _configuration.apiVersion]];
        [sdkInfo appendString:[NSString stringWithFormat:@"&sdkType=iOS_Native"]];
        
        [defaultHeaders setObject:sdkInfo.copy forKey:@"SDKInfo"];
        
        [defaultHeaders setObject:@"application/json" forKey:@"Content-Type"];
        
        config.defaultHeaders = defaultHeaders.copy;
    }
    
    _endpointAPIManager = [[TMEndpointAPIManager alloc] initWithConfiguration:config];
}

@end
