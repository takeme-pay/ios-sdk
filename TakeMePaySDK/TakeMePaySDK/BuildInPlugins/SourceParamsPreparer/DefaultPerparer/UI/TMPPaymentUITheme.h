//
//  TMPPaymentUITheme.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMPPaymentUITheme : NSObject

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *deselectedColor;

@property (nonatomic, strong) NSDictionary *titleAttributes;
@property (nonatomic, strong) NSDictionary *subtitleAttributes;
@property (nonatomic, strong) NSDictionary *bodyAttributes;
@property (nonatomic, strong) NSDictionary *amountAttributes;
@property (nonatomic, strong) NSDictionary *footerAttributes;

@end
