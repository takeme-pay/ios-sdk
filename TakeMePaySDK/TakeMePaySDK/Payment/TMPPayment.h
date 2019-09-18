//
//  TMPPayment.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPSource.h"
#import "TMPSourceParams.h"
#import "TMPPaymentDelegate.h"
#import "TMPPaymentSourceParamsPreparer.h"

@class TMPConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 TMPPayment is the entry class for invoking payment process in TakeMe Pay, you could use the instance of TMPPayment to handle with progress of the payment.
 */
@interface TMPPayment : NSObject

/**
 The basic configuration which created by the information you provided in TMPConstants file, it would be used in payment process.
 */
@property (nonatomic, strong, readonly) TMPConfiguration *configuration;

/**
 The source params preparer acts as a very important role in TMPPayment class, all actions for constructing source params, which means those before `createSource` actions are the responsibilties of source params preparer, also, you could create source by using user interface as well. You need handle with all those pre-actions, then invoke the completion callback.
 */
@property (nonatomic, strong, readonly) id<TMPPaymentSourceParamsPreparer> sourceParamsPreparer;

/**
 Designated initializer of TMPPayment, handles the process of payment.

 @param sourceParams The params be used to create payment instance.
 @param preparer The source params preparer, you should conform TMPPaymentSourceParamsPreparer protocol, then give TMPPayment ready-to-use sourceParams. How to construct the source params is regardless for TMPPayment, once you accomplish the construction process, call the completion block of TMPPaymentSourceParamsPreparer.
 @param delegate The object which received payment notification from TakeMe Pay SDK.
 @return TMPPayment instance, if sourceParams or preparer is nil, the result of the initializer would be nil.
 */
- (nullable instancetype)initWithSourceParams:(TMPSourceParams *)sourceParams sourceParamsPreparer:(id<TMPPaymentSourceParamsPreparer>)preparer delegate:(nullable id<TMPPaymentDelegate>)delegate;

/**
 Once you use proper sourceParams and preparer to create an instance of TMPPayment, invoke this method to start payment process. Normally, after you call this method, the checkout counter should show on the screen immediately.
 */
- (void)startPaymentAction;

/**
 Another version of `startPaymentAction:`, if you use your own source params preparer, and want to receive some values from the caller, you can pass in an dictionary as the userInfo.

 @param userInfo A dictionary you want to pass to your source params preparer.
 */
- (void)startPaymentAction:(nullable NSDictionary *)userInfo;

#pragma mark - unavailable

- (instancetype)init NS_UNAVAILABLE;

@end

@interface TMPPayment (TMPUseDefaultUI)

/**
 Secondary initializer of TMPPayment, use TakeMe Pay SDK built-in checkout counter UI to make a payment, if you don't want to provide a source params preparer yourself, you can use this convenience initializer.

 @param sourceParams The params be used to create payment instance.
 @param delegate The object which received payment notification from TakeMe Pay SDK.
  @return TMPPayment instance, if sourceParams is nil, the result of the initializer would be nil.
 */
- (nullable instancetype)initWithSourceParams:(TMPSourceParams *)sourceParams delegate:(nullable id<TMPPaymentDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
