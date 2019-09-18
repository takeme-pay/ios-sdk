//
//  TMPPaymentUICheckoutCounterFullyCustomizer.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPPaymentUICheckoutCounterLogicResponder.h"
#import "TMPPaymentEnums.h"

@class TMPPaymentMethod, TMPSourceParams;

NS_ASSUME_NONNULL_BEGIN

/**
 The renderer of CheckoutCounter, it has UI abilities as blow.
 */
@protocol TMPPaymentUICheckoutCounterRenderer <NSObject>

@required

/**
 The user actions responder ( delegate ), to handle with user actions.
 */
@property (nonatomic, strong) id<TMPPaymentUICheckoutCounterLogicResponder> responder;

/**
 The item image url, set if your item has one, then it will be shown on the renderer.
 */
@property (nonatomic, strong, nullable) NSString *itemImageUrl;

/**
 The itemDescription of the item, it will be shown on the renderer as itemDescription, not as title, could be nil.
 */
@property (nonatomic, strong, nullable) NSString *itemDescription;

/**
 The extra information of the renderer, for extensible abilities purpose, may be nil.
 */
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/**
 The payment method item which is used in CheckoutCounter renderer. Ut could be nil, if your renderer doesn't deal with any payment method logic.
 */
@property (nonatomic, strong, nullable) TMPPaymentMethod *paymentMethodItem;

/**
 The name of the item, it will be treated as the item title, shown on the renderer.
 */
@property (nonatomic, strong) NSString *itemName;

/**
 The price ( amount ) of the item.
 */
@property (nonatomic, strong) NSNumber *itemPrice;

/**
 The currency of the item.
 */
@property (nonatomic, strong) NSString *itemCurrency;

/**
 The current payment status of the renderer.
 */
@property (nonatomic, assign) TMPPaymentResultState paymentStatus;

@end

NS_ASSUME_NONNULL_END
