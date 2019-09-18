//
//  TMPPayment.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPayment.h"
#import "TMPPaymentAuthorizable.h"
#import "TMPPaymentServiceClient.h"
#import "TMPSourceContext.h"
#import "TMPSourceTypesContext.h"
#import "TMPConfiguration.h"
#import "NSError+TMPErrorGenerator.h"
#import "TMPSourceContext+TMPPrivate.h"
#import "_TMPPaymentLogInformationInterceptor.h"
#import "_TMPPaymentClosureSupportInterceptor.h"
#import "TMPPaymentMethod+TMPPrivate.h"
#import "NSArray+TMFExtension.h"
#import <objc/runtime.h>
#import "TMPPayment+TMPPrivate.h"
#import "TMUtils.h"
#import "TMPPaymentRequestStatePoller.h"

@interface TMPPayment () <TMPPaymentDelegate>

@property (nonatomic, strong) TMPSourceParams *sourceParams;

@property (nonatomic, strong, readwrite) TMPConfiguration *configuration;
@property (nonatomic, strong, readwrite) id<TMPPaymentSourceParamsPreparer> sourceParamsPreparer;
@property (nonatomic, strong) _TMPPaymentLogInformationInterceptor *logInterceptor;
@property (nonatomic, strong) _TMPPaymentClosureSupportInterceptor *closureSupportInterceptor;

@property (nonatomic, strong) TMPPaymentRequestStatePoller *poller;

@property (nonatomic, strong) NSHashTable<id<TMPPaymentDelegate>> *delegates;

@property (nonatomic, assign) TMPPaymentResultState currentState;

@end

@implementation TMPPayment

- (instancetype)initWithSourceParams:(TMPSourceParams *)sourceParams sourceParamsPreparer:(id<TMPPaymentSourceParamsPreparer>)preparer delegate:(id<TMPPaymentDelegate>)delegate {
    NSAssert(sourceParams, @"source params can't be nil");
    NSAssert(preparer, @"preparer can't be nil");
    
    if (self = [super init]) {
        _sourceParams = sourceParams;
        
        _sourceParamsPreparer = preparer;
        _sourceParamsPreparer.payment = self;
        
        _configuration = TMPConfiguration.defaultConfiguration;
        _logInterceptor = [[_TMPPaymentLogInformationInterceptor alloc] init];
        _closureSupportInterceptor = [[_TMPPaymentClosureSupportInterceptor alloc] init];
        self.client = [[TMPPaymentServiceClient alloc] initWithConfiguration:_configuration];
        
        {
            _delegates = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:5];
            [_delegates addObject:self];
            [_delegates addObject:delegate];
            [_delegates addObject:preparer];
            [_delegates addObject:_logInterceptor];
            [_delegates addObject:_closureSupportInterceptor];
        }                
    }
    
    return self;
}

#pragma mark - public

- (void)startPaymentAction {
    [self startPaymentAction:nil];
}

// todo: promise it
- (void)startPaymentAction:(NSDictionary *)userInfo {    
    __weak typeof(self) weakSelf = self;
    
    TMPSourceTypesContext *context = [[TMPSourceTypesContext alloc] initWithClient:self.client];
    [context retrieveSourceTypes:^(NSArray<TMPPaymentMethod *> * _Nullable items, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf dispatchDelegateMethod:@selector(payment:didReceivedSourceTypes:selectedSourceType:error:userInfo:) args:@[self, [items isKindOfClass:NSArray.class] ? [items tmf_map:^NSString * _Nonnull(TMPPaymentMethod * _Nonnull paymentMethod) {
                return paymentMethod.paymentMethodId;   // for rising up the test coverage ratio, just return paymentMethodId, `retrieveSourceTypes:` can guarantee the type of object
            }] : NSNull.null, items.firstObject.paymentMethodId ?: NSNull.null, error ?: NSNull.null, NSNull.null]];
            
            // this moment, the sourceParamsPreparer doesn't manage the payment flow yet, dispatch the will/didFinishWithState with failure state directly
            if (error) {
                [strongSelf dispatchDelegateMethod:@selector(payment:willFinishWithState:error:userInfo:) args:@[strongSelf, @(TMPPaymentResultStateFailure), error, NSNull.null]];
                
                [strongSelf dispatchDelegateMethod:@selector(payment:didFinishWithState:error:userInfo:) args:@[strongSelf, @(TMPPaymentResultStateFailure), error, NSNull.null]];
                
                return;
            }
            
            [strongSelf.sourceParamsPreparer prepareSourceParams:strongSelf.sourceParams availableSourceTypes:items userInfo:userInfo decoratedSourceParams:^(TMPSourceParams * _Nonnull decoratedSourceParams) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {                    
                    TMPPaymentMethod *paymentMethod = strongSelf.sourceParamsPreparer.paymentMethod;
                    
                    [paymentMethod payment:strongSelf processSourceParams:strongSelf.sourceParams userInfo:userInfo completion:^(TMPSourceParams * _Nullable decoratedSource) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (strongSelf) {
                            strongSelf.sourceParams = decoratedSourceParams;
                            if (strongSelf.sourceParams) {
                                [strongSelf dispatchDelegateMethod:@selector(payment:willCreateSourceByUsing:) args:@[strongSelf, strongSelf.sourceParams]];
                                
                                TMPSourceContext *context = [[TMPSourceContext alloc] initWithClient:strongSelf.client];
                                [context createSourceWithParams:strongSelf.sourceParams completion:^(TMPSource * _Nullable source, NSError * _Nullable error) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    if (strongSelf) {
                                        [strongSelf dispatchDelegateMethod:@selector(payment:didCreateSource:error:userInfo:) args:@[strongSelf, source ?: NSNull.null, error ?: NSNull.null, NSNull.null]];
                                        
                                        if (error) {
                                            return;
                                        }
                                        
                                        // the method should be called on the main queue
                                        [TMUtils executeOnMainQueue:^{
                                            [paymentMethod requestPaymentAuthorization:strongSelf source:source userInfo:userInfo completion:^(TMPPaymentAuthorizationState authorizationState, NSError * _Nullable error) {
                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                if (strongSelf) {
                                                    [strongSelf dispatchDelegateMethod:@selector(payment:didFinishAuthorization:error:userInfo:) args:@[strongSelf, @(authorizationState), error ?: NSNull.null, NSNull.null]];
                                                    
                                                    if (error) {
                                                        return;
                                                    }
                                                    
                                                    // if the auth successful, polling the result from our backend
                                                    strongSelf.poller = [[TMPPaymentRequestStatePoller alloc] initWithClient:strongSelf.client clientSecret:source.clientSecret sourceId:source.sourceId timeout:userInfo[@"__timeout"] ? [userInfo[@"__timeout"] doubleValue] : NAN completion:^(TMPPaymentPollingResultState state, NSError * _Nonnull error) {
                                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                                        if (strongSelf) {
                                                            [strongSelf dispatchDelegateMethod:@selector(payment:didPolledSource:state:error:userInfo:) args:@[strongSelf, source, @(state), error ?: NSNull.null, NSNull.null]];
                                                        }
                                                    }];
                                                }
                                            }];
                                        } sync:NO];
                                    }
                                }];
                            }
                        }
                    }];
                }
            } completion:^(TMPPaymentResultState currentState, NSError * _Nullable error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    strongSelf.currentState = currentState;
                    
                    [strongSelf dispatchDelegateMethod:@selector(payment:willFinishWithState:error:userInfo:) args:@[strongSelf, @(strongSelf.currentState), error ?: NSNull.null, NSNull.null]];
                    
                    [strongSelf dispatchDelegateMethod:@selector(payment:didFinishWithState:error:userInfo:) args:@[strongSelf, @(strongSelf.currentState), error ?: NSNull.null, NSNull.null]];
                }
            }];
        }
    }];
}

#pragma mark - private

- (void)dispatchDelegateMethod:(SEL)selector args:(NSArray *)args {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<TMPPaymentDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:selector]) {
                NSMethodSignature *signature = [delegate.class instanceMethodSignatureForSelector:selector];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                
                invocation.selector = selector;
                invocation.target = delegate;
                
                [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:NSNull.class]) {
                        // for enums...
                        if ([obj isKindOfClass:NSNumber.class]) {
                            NSInteger objInteger = [obj integerValue];
                            [invocation setArgument:&objInteger atIndex:idx + 2];
                        } else {
                            [invocation setArgument:&obj atIndex:idx + 2];
                        }
                    }
                }];
                
                [invocation invoke];
            }
        }
    });
}

#pragma mark - TMPPaymentDelegate

- (void)payment:(TMPPayment *)payment didFinishWithState:(TMPPaymentResultState)state error:(nullable __unused NSError *)error userInfo:(nullable __unused NSDictionary *)userInfo {
    self.sourceParamsPreparer = nil;
    
    [self.poller stopPolling];
    self.poller = nil;
}

@end

#import "TMPUIPaymentSourceParamsPreparer.h"

@implementation TMPPayment (TMPUseDefaultUI)

- (nullable instancetype)initWithSourceParams:(TMPSourceParams *)sourceParams delegate:(id<TMPPaymentDelegate>)delegate {
    return [self initWithSourceParams:sourceParams sourceParamsPreparer:[[TMPUIPaymentSourceParamsPreparer alloc] init] delegate:delegate];
}

@end
