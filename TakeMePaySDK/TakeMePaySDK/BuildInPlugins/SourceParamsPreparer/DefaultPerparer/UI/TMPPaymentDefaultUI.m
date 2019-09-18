//
//  TMPPaymentDefaultUI.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentDefaultUI.h"
#import "TMPPaymentDefaultUICheckoutCounterViewController.h"
#import "TMPPaymentDefaultUIPaymentMethodViewController.h"

@interface TMPPaymentDefaultUI ()

@property (nonatomic, strong) TMPPaymentUITheme *theme;

@end

@implementation TMPPaymentDefaultUI

#pragma mark - TMPPaymentUIFullyCustomizer

- (nonnull UIViewController<TMPPaymentUICheckoutCounterRenderer> *)homeViewController {
    UIViewController<TMPPaymentUICheckoutCounterRenderer> *viewController = [[TMPPaymentDefaultUICheckoutCounterViewController alloc] initFromTheme:self.theme];
    
    return viewController;
}

- (nonnull UIViewController<TMPPaymentUIPaymentMethodRenderer> *)paymentMethodViewController {
    UIViewController<TMPPaymentUIPaymentMethodRenderer> *viewController = [[TMPPaymentDefaultUIPaymentMethodViewController alloc] initFromTheme:self.theme];
    
    return viewController;
}

#pragma mark - TMPPaymentUIThemeAcceptable

- (void)setUITheme:(nonnull TMPPaymentUITheme *)theme {
    self.theme = theme;
    // todo: maybe multithread problem here when set theme / pushing vc simultaneously
}

- (nullable TMPPaymentUITheme *)currentUITheme {
    return self.theme;
}

@end
