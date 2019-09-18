//
//  TMPDefaultPaymentAnimator.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/4.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPDefaultPaymentAnimator : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithDuration:(NSTimeInterval)duration operation:(UINavigationControllerOperation)operation;

@end

NS_ASSUME_NONNULL_END
