//
//  TMPPaymentDelegate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TMPPaymentEnums.h"

@class TMPPayment, TMPSource, TMPSourceParams;

/**
 Provides necessary and detailed information for payment progress delegate, all methods are optional, when you init TMPPayment instance, you are asked to provide a delegate instance.
 All methods will be invoked on MAIN_QUEUE
 */
@protocol TMPPaymentDelegate <NSObject>

NS_ASSUME_NONNULL_BEGIN

@optional

/**
 Invoked instantly before using the params to create the source by requesting TakeMe Pay backend.

 @param payment Associated TMPPayment instance.
 @param params The final ( will be used for requesting very soon ) params.
 */
- (void)payment:(TMPPayment *)payment willCreateSourceByUsing:(TMPSourceParams *)params;

/**
 Invoked when request TakeMe Pay backend completed, the source would be present if the create process was successful, or the error would be present.

 @param payment Associated TMPPayment instance.
 @param source The source created by the params, is nil if process failed.
 @param error The error of source create process, is nil if process successful.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)payment:(TMPPayment *)payment didCreateSource:(nullable TMPSource *)source error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

/**
 Invoked when TMPPayment received the source types of current merchant, the useful information will pass to delegate.

 @param payment Associated TMPPayment instance.

 @param sourceTypes Available source types of the associated merchant.
 @param selectedSourceType Current selected ( default ) source type of the associated merchant.
 @param error Error is present if receive source types process failed.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)payment:(TMPPayment *)payment didReceivedSourceTypes:(nullable NSArray<NSString *> *)sourceTypes selectedSourceType:(nullable NSString *)selectedSourceType error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

/**
 Called when authorization finished, authorization includes many kind of ways, for example, jump to wechat app for asking user to confirm the amount and then input password.

 @param payment Associated TMPPayment instance.
 @param state Result state of current authorization.
 @param error Error of authorization.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)payment:(TMPPayment *)payment didFinishAuthorization:(TMPPaymentAuthorizationState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

/**
 After payment authorization finished, the TMPPayment will start to poll the result of current source, once the poller gets the successful result, current payment will finish soon, and the willFinishWithState: and didFinishWithState: will be called.

 @param payment Associated TMPPayment instance.
 @param state Result state of current polling.
 @param error Error of polling source result.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)payment:(TMPPayment *)payment didPolledSource:(nullable TMPSource *)source state:(TMPPaymentPollingResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

/**
 Tell delegates the payment will finish soon, this moment the payment has done, the plugins like sourceParamsPreparer could use this method to clean the state, willFinishWithState and didFinishWithState can't be interrupted.

 @param payment Associated TMPPayment instance.
 @param state Result state of current payment.
 @param error Error of payment, if error occurred before, it would be the latest error.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)payment:(TMPPayment *)payment willFinishWithState:(TMPPaymentResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

/**
 Invoked when the whole payment process finished.

 @param payment Associated TMPPayment instance.
 @param state Result state of current payment.
 @param error Error of payment, if error occurred before, it would be the latest error.
 @param userInfo Extra information, for extensible abilities in the future.
 */
- (void)payment:(TMPPayment *)payment didFinishWithState:(TMPPaymentResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

NS_ASSUME_NONNULL_END

@end
