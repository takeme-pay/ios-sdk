//
//  TMPUIPaymentSourceParamsPreparer.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/17.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPUIPaymentSourceParamsPreparer.h"
#import "TMPPaymentUICheckoutCounterRenderer.h"
#import "TMPPaymentUIPaymentMethodRenderer.h"
#import "TMPPaymentMethodItem+TMPUIInfo.h"
#import "TMPPaymentUIFullyCustomizer.h"
#import "TMPPaymentUIThemeAcceptable.h"
#import "TMPPaymentDefaultUI.h"
#import "TMPDefaultPaymentVCPresenter.h"
#import "TMPSourceTypeListParams.h"
#import "TMUtils.h"
#import "NSArray+TMFExtension.h"
#import <objc/runtime.h>

@interface TMPSourceParams (TMPSourceItemImage)

- (NSString *)itemImageUrl;
- (void)setItemImageUrl:(NSString *)itemImageUrl;

@end

@implementation TMPSourceParams (TMPSourceItemImage)

- (NSString *)itemImageUrl {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setItemImageUrl:(NSString *)itemImageUrl {
    if (!itemImageUrl) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(itemImageUrl), itemImageUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface TMPUIPaymentSourceParamsPreparer () <TMPPaymentUICheckoutCounterLogicResponder, TMPPaymentUIPaymentMethodLogicResponder>

@property (nonatomic, strong) TMPPaymentMethod *selectedPaymentMethod;
@property (nonatomic, strong) NSArray<TMPPaymentMethod *> *sourceTypes;
@property (nonatomic, strong) TMPSourceParams *sourceParams;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong, nullable) id<TMPPaymentUIFullyCustomizer, TMPPaymentUIThemeAcceptable> uiImplementor;
@property (nonatomic, strong) id<TMPPaymentVCPresenter> vcPresenter;

@property (nonatomic, weak) UIViewController<TMPPaymentUICheckoutCounterRenderer> *checkoutCounterRenderer;
@property (nonatomic, weak) UIViewController<TMPPaymentUIPaymentMethodRenderer> *paymentMethodRenderer;

@property (nonatomic, copy) void(^decoratedSourceParamsBlock)(TMPSourceParams *);
@property (nonatomic, copy) void(^completion)(TMPPaymentResultState, NSError * _Nullable);

@end

@implementation TMPUIPaymentSourceParamsPreparer

@synthesize payment = _payment;
@synthesize latestError = _latestError;

- (instancetype)init {
    if (self = [super init]) {
        _uiImplementor = [[TMPPaymentDefaultUI alloc] init];
        _vcPresenter = [[TMPDefaultPaymentVCPresenter alloc] init];
    }
    return self;
}

#pragma mark - override

- (TMPPaymentMethod *)paymentMethod {
    return self.selectedPaymentMethod;
}

#pragma mark - private

- (void)showFailureAndRestoreStateToIdle {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.checkoutCounterRenderer.paymentStatus = TMPPaymentResultStateFailure;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.checkoutCounterRenderer.paymentStatus = TMPPaymentResultStateIdle;
        });
    });
}

#pragma mark - TMPPaymentSourceParamsProcessable

- (void)prepareSourceParams:(TMPSourceParams *)rawSourceParams availableSourceTypes:(NSArray<TMPPaymentMethod *> *)sourceTypes userInfo:(NSDictionary *)userInfo decoratedSourceParams:(nonnull void (^)(TMPSourceParams * _Nonnull))decoratedSourceParamsBlock completion:(nonnull void (^)(TMPPaymentResultState, NSError * _Nullable))completion {
    self.decoratedSourceParamsBlock = decoratedSourceParamsBlock;
    self.completion = completion;
    self.sourceParams = rawSourceParams;
    self.userInfo = userInfo;
    
    if (![sourceTypes isKindOfClass:NSArray.class]) {
        if (decoratedSourceParamsBlock) {
            decoratedSourceParamsBlock(rawSourceParams);
        }
        return;
    }
    
    // fulfill details of payment methods
    {
        TMPPaymentMethod *firstItem = sourceTypes.firstObject;
        if ([firstItem isKindOfClass:TMPPaymentMethod.class]) {
            firstItem.tmp_selected = YES;
        }
    }
        
    self.sourceTypes = sourceTypes;
    
    UIViewController<TMPPaymentUICheckoutCounterRenderer> *paymentRootRenderer = self.uiImplementor.homeViewController;
    self.checkoutCounterRenderer = paymentRootRenderer;
    
    if ([paymentRootRenderer isKindOfClass:UIViewController.class] && [paymentRootRenderer conformsToProtocol:@protocol(TMPPaymentUICheckoutCounterRenderer)]) {
        
        // todo: refactoring by redux-like one way data flow
        paymentRootRenderer.responder = self;
        paymentRootRenderer.itemName = self.sourceParams.sourceDescription;
        paymentRootRenderer.itemImageUrl = self.sourceParams.itemImageUrl;
        paymentRootRenderer.itemPrice = self.sourceParams.amount;
        paymentRootRenderer.itemCurrency = self.sourceParams.currency;
        paymentRootRenderer.paymentStatus = TMPPaymentResultStateIdle;
        
        __block TMPPaymentMethod *selectedItem;
        [self.sourceTypes enumerateObjectsUsingBlock:^(TMPPaymentMethod * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tmp_selected) {
                selectedItem = obj;
                *stop = YES;
            }
        }];
        
        paymentRootRenderer.paymentMethodItem = selectedItem;
        self.selectedPaymentMethod = selectedItem;
        
        [self.vcPresenter payment:self.payment showPaymentViewController:paymentRootRenderer completion:nil];
    }
}

#pragma mark - TMPPaymentUICheckoutCounterLogicResponder

- (void)checkoutCounter:(UIViewController<TMPPaymentUICheckoutCounterRenderer> *)checkoutCounter payPressed:(NSDictionary *)userInfo {
    // re-assign latest error as nil, it means the preparer starts a new payment
    self.latestError = nil;
    
    checkoutCounter.paymentStatus = TMPPaymentResultStateInProgress;

    if (self.decoratedSourceParamsBlock) {
        self.decoratedSourceParamsBlock(self.sourceParams);
    }
}

- (void)dismissCheckoutCounter:(UIViewController<TMPPaymentUICheckoutCounterRenderer> *)checkoutCounter {
    if (self.checkoutCounterRenderer.paymentStatus == TMPPaymentResultStateInProgress) {
        return;
    }
    
    [self.vcPresenter payment:self.payment dismissPaymentViewController:checkoutCounter completion:^{
        if (self.completion) {
            self.completion(TMPPaymentResultStateCanceled, self.latestError);
        }
    }];
}

- (void)checkoutCounter:(UIView<TMPPaymentUICheckoutCounterRenderer> *)checkoutCounter changePaymentMethodPressed:(NSDictionary *)userInfo {
    UIViewController<TMPPaymentUIPaymentMethodRenderer> *paymentMethodRenderer = self.uiImplementor.paymentMethodViewController;
    self.paymentMethodRenderer = paymentMethodRenderer;

    if ([paymentMethodRenderer isKindOfClass:UIViewController.class] && [paymentMethodRenderer conformsToProtocol:@protocol(TMPPaymentUIPaymentMethodRenderer)]) {

        // todo: refactoring by redux-like one way data flow
        paymentMethodRenderer.items = self.sourceTypes;
        paymentMethodRenderer.responder = self;
        paymentMethodRenderer.userInfo = userInfo;

        [self.vcPresenter payment:self.payment showPaymentViewController:paymentMethodRenderer completion:nil];
    }
}

#pragma mark - TMPPaymentUIPaymentMethodLogicResponder

- (void)paymentMethodView:(UIViewController<TMPPaymentUIPaymentMethodRenderer> *)paymentMethodView didSelect:(nonnull TMPPaymentMethod *)paymentMethodItem atIndex:(__unused NSInteger)index {
    for (TMPPaymentMethod *item in self.sourceTypes) {
        item.tmp_selected = [item.paymentMethodId isEqualToString:paymentMethodItem.paymentMethodId];
    }

    // todo: refactoring by redux-like one way data flow
    paymentMethodView.items = self.sourceTypes;
    self.checkoutCounterRenderer.paymentMethodItem = paymentMethodItem;
    self.selectedPaymentMethod = paymentMethodItem;

    [self.vcPresenter payment:self.payment dismissPaymentViewController:paymentMethodView completion:nil];
}

#pragma mark - TMPPaymentDelegate

- (void)payment:(TMPPayment *)payment didCreateSource:(TMPSource *)source error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error) {
        self.latestError = error;
        
        [self showFailureAndRestoreStateToIdle];
    }
}

- (void)payment:(TMPPayment *)payment didFinishAuthorization:(TMPPaymentAuthorizationState)state error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error) {
        self.latestError = error;
        
        [self showFailureAndRestoreStateToIdle];
    }
}

- (void)payment:(TMPPayment *)payment didPolledSource:(TMPSource *)source state:(TMPPaymentPollingResultState)state error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (error) {
        self.latestError = error;
        
        if (state == TMPPaymentPollingResultStateTimeout) {
            // error occurred in polling phrase, we assume that user has paid successfully ( because only if the user authorize their payment successfully, the payment flow will get to here ), but the SDK can't get the result from TakeMePay backend now ( might be network issues )
            self.checkoutCounterRenderer.paymentStatus = TMPPaymentResultStatePossibleSuccess;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.vcPresenter payment:payment dismissPaymentViewController:self.checkoutCounterRenderer completion:^{
                    if (self.completion) {
                        self.completion(TMPPaymentResultStatePossibleSuccess, nil);
                    }
                }];
            });
        } else {
            [self showFailureAndRestoreStateToIdle];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (state == TMPPaymentPollingResultStateSuccess) {
                self.checkoutCounterRenderer.paymentStatus = TMPPaymentResultStateSuccess;
                
                if ([self.userInfo isKindOfClass:NSDictionary.class] && [self.userInfo[@"useTapicEngine"] boolValue] && UINotificationFeedbackGenerator.class) {
                    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                    [generator prepare];
                    [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.vcPresenter payment:payment dismissPaymentViewController:self.checkoutCounterRenderer completion:^{
                        if (self.completion) {
                            self.completion(TMPPaymentResultStateSuccess, nil);
                        }
                    }];
                });                                
            } else if (state == TMPPaymentPollingResultStateFailure) {
                [self showFailureAndRestoreStateToIdle];
            }
        });
    }
}

@end
