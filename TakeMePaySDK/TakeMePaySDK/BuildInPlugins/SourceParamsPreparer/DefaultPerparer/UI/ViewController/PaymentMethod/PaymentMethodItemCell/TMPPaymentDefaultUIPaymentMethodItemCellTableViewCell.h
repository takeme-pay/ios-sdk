//
//  TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/3.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMPPaymentMethod;

FOUNDATION_EXPORT NSString * __nonnull const TMP_DEFAULT_PAYMENT_METHOD_ITEM_REUSE_IDENTIFIER;

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell : UITableViewCell

- (void)configCellFrom:(TMPPaymentMethod *)item;

@end

NS_ASSUME_NONNULL_END
