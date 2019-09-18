//
//  TMPPaymentMethod.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMDictionaryConvertible.h"
#import "TMPPaymentSourceParamsProcessable.h"
#import "TMPPaymentAuthorizable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a type of payment method.
 */
@interface TMPPaymentMethod : NSObject <TMDictionaryConvertible, TMPPaymentSourceParamsProcessable, TMPPaymentAuthorizable>

/**
 The type identifier of the payment method, unique.
 */
@property (nonatomic, strong, readonly) NSString *paymentMethodId;

/**
 The title of the payment method, it might be different from the `paymentMethodId` ( in usual case )
 */
@property (nonatomic, strong, readonly) NSString *title;

/**
 The icon(s) of payment method, it might be nil.
 */
@property (nonatomic, nullable, strong, readonly) NSArray<NSString *> *iconUris;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("Should always use the result from TMPPaymentServiceClient+TMPSourceTypeListLowLevelInfoManipulatorSupport")));

@end

@interface TMPPaymentMethod (TMPPaymentMethodAvailability)

/**
 Subclass override it.
 
 If the payment method is available, it's the responsiblity of the source params preparer to check if the payment method can be used.
 For example, if user's device doesn't install WeChat app but the user wants to use WeChat Pay as payment method, the available of the method should be NO.
 For those methods which ignore the external environment, the available should always return YES.
 */
@property (nonatomic, assign, readonly) BOOL available;

/**
 If the payment method is unavailable, it should provide more helpful and useful description of the unavailability, for debugging logs.
 */
@property (nonatomic, nullable, strong, readonly) NSString *unavailableReason;

@end

NS_ASSUME_NONNULL_END
