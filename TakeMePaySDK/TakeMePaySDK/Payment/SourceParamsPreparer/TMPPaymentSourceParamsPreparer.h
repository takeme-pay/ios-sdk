//
//  TMPPaymentSourceParamsPreparer.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/12.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPPaymentDelegate.h"

@class TMPPayment, TMPPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

@protocol TMPPaymentSourceParamsPreparer <NSObject, TMPPaymentDelegate>

@required
/**
 Parent TMPPayment instance, here use strong reference because we want to make a retain recycle, so that user can just create a TMPPayment instance and doesn't need to retain it.
 */
@property (nonatomic, strong) TMPPayment *payment;

/**
 The latest error the preparer received from TMPPayment by listening TMPPaymentDelegate methods
 */
@property (nonatomic, strong, nullable) NSError *latestError;

/**
 Abstract method, subclass should override it.
 
 Return the desired payment method you got from TMPSourceTypesContext previously, this method would be called after you call `completion` callback of TMPPaymentSourceParamsProcessable method, your `payment:processSourceParams:completion:` method could ignore processing payment method related logic, TMPPayment would handle with it.
 
 @return payment method instance
 */
- (TMPPaymentMethod *)paymentMethod;

/**
 Abstract method, subclass should override it.
 
 Decorate the source params, it should pass the final source params ( means it could be used to create source ) to the completion in any cases. This method may be a good place for you to do any UI actions, TMPPayment always waiting for your completion block invoking.
 IMPORTANT: Whether in the case of success or failure, you should and must always call completion, otherwise, the TMPPayment might be in memory leaked status.
 
 @param rawSourceParams Raw source params, may only contains very limit information provided by you in the init method of TMPPayment.
 @param sourceTypes All available source types of the merchant, you should always use source types with it.
 @param userInfo Reserved for future, not used now.
 @param decoratedSourceParamsBlock Pass in your decorated source params to this block
 @param completion You must call this completion callback in any cases, if the payment is no longer needed, pass nil ( e.g. you are going to dismiss the checkout counter view, the payment is no longer needed in this case, pass nil after dismiss the UI in preparer, if you pass non-nil value into completion block, it would rise a payment process up, no matter it's the first time or the second time be called ). The completion MAY be retained by the decorator, you should always assume it would be retained.
 */
- (void)prepareSourceParams:(TMPSourceParams *)rawSourceParams availableSourceTypes:(NSArray<TMPPaymentMethod *> *)sourceTypes userInfo:(nullable NSDictionary *)userInfo decoratedSourceParams:(void(^)(TMPSourceParams *decoratedSourceParams))decoratedSourceParamsBlock completion:(void(^)(TMPPaymentResultState currentState, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
