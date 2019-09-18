//
//  TakeMePay.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/25.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMPURLListener;

NS_ASSUME_NONNULL_BEGIN

/**
 The class you use in AppDelegate to handle with redirection case, may be used in other use cases in the future. It could be seen as the public interface of TakeMe Pay SDK.
 */
@interface TakeMePay : NSObject

/**
 Publishable key before use TakeMePay
 */
@property (class) NSString *publicKey;

/**
 Your company name, it may be used for user interface display
 */
@property (class, nullable) NSString *companyName;

/**
 Distributed url scheme host.
 */
@property (class, nullable) NSString *distributedUrlSchemeHost;

/**
 AppId on Wechat Open Platform
 */
@property (class, nullable) NSString *wechatPayAppId;

/**
 Use it in `application:openURL:options:` method of your AppDelegate.m, it will handle with the scheme you registered in TakeMe Pay SDK ( TMPConstants.h ).

 @param url The scheme passing to your application.
 @return Return YES if the url is in TakeMe Pay SDK scope.
 */
+ (BOOL)shouldHandleWithUrl:(NSURL *)url;

@end

@interface TakeMePay (TMPRegisterURLListener)

/**
 This method is used by TakeMe Pay SDK, we use this method to register url listener when redirection occurs, because all payment could be separated library, so we leave this register entry public, you should never use it.

 @param listener The listener who response to redirection
 */
+ (void)registerListener:(id<TMPURLListener>)listener;

@end

NS_ASSUME_NONNULL_END
