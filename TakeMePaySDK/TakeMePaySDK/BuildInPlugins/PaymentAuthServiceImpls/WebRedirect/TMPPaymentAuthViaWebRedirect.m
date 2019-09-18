//
//  TMPPaymentAuthViaWebRedirect.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentAuthViaWebRedirect.h"
#import "TMUtils.h"
#import "TMPSource.h"
#import "TakeMePay.h"
#import "NSError+TMPErrorGenerator.h"
#import "TMPPayment.h"
#import "TMPConfiguration.h"
#import "TMPSourceParams+TMPPrivate.h"
#import "TakeMePay+TMPPrivate.h"
#import <SafariServices/SafariServices.h>
#import "TMPDefaultPaymentVCPresenter.h"
#import "TMPPayment+TMPPrivate.h"
#import "TMPPaymentMethodRegisterSupport.h"
#import "TMPPaymentMethod+TMPPrivate.h"

static NSString *const TMP_HANDLE_REDIRECT_RETURN_BACK_SCHEME_PATH = @"handleRedirectReturn";

@interface TMPPaymentAuthViaWebRedirect () <SFSafariViewControllerDelegate>

@property (nonatomic, weak) TMPPayment *parentPayment;
@property (nonatomic, strong) TMPSource *source;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic, strong) NSURL *redirectUrl;   // only used for app-web redirection
@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, copy) void(^callback)(TMPPaymentAuthorizationState requestState, NSError *error);
@property (nonatomic, strong) id<TMPPaymentVCPresenter> vcPresenter;

@end

@implementation TMPPaymentAuthViaWebRedirect

#pragma mark - TMPPaymentAuthorizable

- (void)requestPaymentAuthorization:(TMPPayment *)payment source:(TMPSource *)source userInfo:(NSDictionary *)userInfo completion:(void (^)(TMPPaymentAuthorizationState, NSError * _Nullable))completion {
    NSAssert([payment isKindOfClass:TMPPayment.class], @"payment can't be nil");
    NSAssert([source isKindOfClass:TMPSource.class], @"source can't be nil");
    NSAssert(completion, @"callback can't be nil");
    
    self.parentPayment = payment;
    self.source = source;
    self.userInfo = userInfo;
    self.callback = completion;
    
    self.vcPresenter = [[TMPDefaultPaymentVCPresenter alloc] init];
    self.redirectUrl = source.redirect.redirectUrl;
    
    if ([self.redirectUrl isKindOfClass:NSURL.class]) {
        [self startRedirectProcess];
        return;
    }
    
    self.callback(TMPPaymentAuthorizationStateFailure, [NSError tmp_normalizeRedirectTypeFromSourceError:self.source]);
}

#pragma mark - TMPPaymentSourceParamsProcessable

- (void)payment:(TMPPayment *)payment processSourceParams:(TMPSourceParams *)params userInfo:(nullable NSDictionary *)userInfo completion:(nonnull void (^)(TMPSourceParams * _Nonnull))completion {
    if (completion) {
        params.redirectReturnUrl = self.returnUrl.absoluteString;
        completion(params);
    }
}

#pragma mark - private

- (void)startRedirectProcess {
    [TakeMePay registerListener:self];
    
    [self openWebUrl:self.redirectUrl];
}

- (void)openWebUrl:(NSURL *)url {
    if (![url isKindOfClass:NSURL.class]) {
        self.callback(TMPPaymentAuthorizationStateFailure, [NSError tmp_openUrlErrorWhenRedirect:url source:self.source channel:@"web"]);
        return;
    }
    
    self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    self.safariViewController.delegate = self;
    
    [self.vcPresenter payment:self.parentPayment showPaymentViewController:self.safariViewController completion:nil];
}

- (void)urlHandleCallback:(NSURL *)url {
    [TMUtils executeOnMainQueue:^{
        if (self.safariViewController) {
            [self.vcPresenter payment:self.parentPayment dismissPaymentViewController:self.safariViewController completion:nil];
            self.safariViewController = nil;
        }
        
        if (self.callback) {
            // arbitrary success, let TMPPayment polls the result
            self.callback(stateFromUrl(url), nil);
        }
    } sync:NO];
}

static inline TMPPaymentAuthorizationState stateFromUrl(NSURL *url) {
    // NOTE: I believe that this validation part needs re-design, at least, the web redirection module should expose an interface to caller, to make the decision if url is valid state, because we may have various type and format of urls from separated payment brand, not in an unified way.
    // now, just return arbitrary success, let TMPPayment polls the result
    return TMPPaymentAuthorizationStateSuccess;
}

#pragma mark - TMPURLListener

- (BOOL)shouldHandleWithUrl:(NSURL *)url {
    if ([url isEqual:self.returnUrl]) {
        [self urlHandleCallback:url];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - utils

- (NSURL *)returnUrl {
    NSAssert(![TMUtils stringIsEmpty:self.parentPayment.configuration.distributedUrlSchemeHost], @"if use webview redirect, distributedUrlSchemeHost can't be nil, nor you can't jump back");
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = self.parentPayment.configuration.distributedUrlSchemeHost;
    components.host = TMP_HANDLE_REDIRECT_RETURN_BACK_SCHEME_PATH;
    components.query = self.uuidString;
    
    return components.URL;
}

#pragma mark - getters

- (NSString *)uuidString {
    if (!_uuidString) {
        _uuidString = NSUUID.UUID.UUIDString;
    }
    return _uuidString;
}

@end
