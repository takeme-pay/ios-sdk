//
//  TMPSourceTypesContext.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/16.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPPaymentServiceClient, TMPPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

@interface TMPSourceTypesContext : NSObject

@property (nonatomic, strong, readonly) TMPPaymentServiceClient *client;

/**
 Designated initializer of TMPSourceTypesContext, client is required.
 
 @param client Handles network connection with TakeMe SDK backend, you could use TMPPaymentServiceClient with default TMPConfiguration.
 @return Source context instance, if client is nil, the return result would be nil.
 */
- (instancetype)initWithClient:(TMPPaymentServiceClient *)client;

/**
 Retrieve available source types, the available source types associated with merchant, the source params preparer should use given sourceList to ask a payment.

 @param completion The completion.
 */
- (void)retrieveSourceTypes:(void(^)(NSArray<TMPPaymentMethod *> * _Nullable sourceList, NSError * _Nullable error))completion;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("You can't instantiate TMPSourceContext directly, use the designated initializer instead.")));

@end

NS_ASSUME_NONNULL_END
