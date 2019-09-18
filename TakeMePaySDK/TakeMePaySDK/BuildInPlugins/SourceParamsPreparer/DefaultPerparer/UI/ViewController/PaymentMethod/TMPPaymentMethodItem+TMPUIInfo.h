//
//  TMPPaymentMethod+TMPUIInfo.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/21.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentMethod (TMPUIInfo)

/**
 Indicates if the payment method is selected.
 */
@property (nonatomic, assign) BOOL tmp_selected;

/**
 The subtitle of the payment method, it might be nil.
 */
@property (nonatomic, nullable, strong) NSString *tmp_subtitle;

/**
 The description of the payment method, it might be nil.
 */
@property (nonatomic, nullable, strong) NSString *tmp_itemDescription;

@end

NS_ASSUME_NONNULL_END
