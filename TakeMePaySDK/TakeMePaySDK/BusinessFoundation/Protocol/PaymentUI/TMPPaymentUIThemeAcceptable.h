//
//  TMPPaymentUICustomizer.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TMPPaymentUITheme.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TMPPaymentUIThemeAcceptable

@required
- (void)setUITheme:(TMPPaymentUITheme *)theme;
- (nullable TMPPaymentUITheme *)currentUITheme;

@optional
- (instancetype)initFromTheme:(TMPPaymentUITheme *)theme; // todo: consider later, weired and not intuitive enough

@end

NS_ASSUME_NONNULL_END
