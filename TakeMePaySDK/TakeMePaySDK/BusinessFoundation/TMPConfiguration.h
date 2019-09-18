//
//  TMPConfiguration.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPConfiguration : NSObject

/**
 Publishable key, it will be fetched from TMPConstants.h.
 */
@property (nonatomic, strong, readonly) NSString *publicKey;

/**
 Base url for TakeMe Pay SDK network connection, can't be modified.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 API version of TakeMe Pay SDK, can't be modified.
 */
@property (nonatomic, strong, readonly) NSString *apiVersion;

/**
 Your company name, it will be fetched from TMPContants.h.
 */
@property (nonatomic, strong, readonly) NSString *companyName;

/**
 The url scheme host which was distributed from TakeMe Pay platform.
 */
@property (nonatomic, strong, readonly) NSString *distributedUrlSchemeHost;

/**
 Return the configuration which read information from TMPConstants.h automatically.

 @return configuration instance.
 */
+ (instancetype)defaultConfiguration;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("Use `defaultConfiguration` instead")));

@end

NS_ASSUME_NONNULL_END
