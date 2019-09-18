//
//  TMPPayment+TMPPrivate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/22.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>

@class TMPPaymentServiceClient;

NS_ASSUME_NONNULL_BEGIN

@interface TMPPayment (TMPPrivate)

/**
 The client is used for network connection between TakeMePay backend and SDK.
 */
@property (nonatomic, strong) TMPPaymentServiceClient *client;

@end

NS_ASSUME_NONNULL_END
