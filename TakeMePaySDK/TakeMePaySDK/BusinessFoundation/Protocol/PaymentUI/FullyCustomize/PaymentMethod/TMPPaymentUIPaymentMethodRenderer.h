//
//  TMPPaymentUIPaymentMethodFullyCustomizer.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TMPPaymentUIPaymentMethodLogicResponder.h"
#import "TMPPaymentMethod.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The renderer of Payment Method, it has UI abilities as blow.
 */
@protocol TMPPaymentUIPaymentMethodRenderer <NSObject>

@required

/**
 The user actions responder ( delegate ), to handle with user actions.
 */
@property (nonatomic, strong) id<TMPPaymentUIPaymentMethodLogicResponder> responder;

/**
 The payment methods your renderer needs to render.
 */
@property (nonatomic, strong) NSArray<TMPPaymentMethod *> *items;

/**
 The extra information of the renderer, for extensible abilities purpose, may be nil.
 */
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

@end

NS_ASSUME_NONNULL_END
