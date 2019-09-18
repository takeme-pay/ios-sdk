//
//  TMPPaymentClient.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentServiceClient : NSObject

@property (nonatomic, strong, readonly) TMPConfiguration *configuration;

- (instancetype)initWithConfiguration:(TMPConfiguration *)configuration;

#pragma mark - unavailable

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
