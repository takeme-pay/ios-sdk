//
//  TMPSource.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMDictionaryConvertible.h"
#import "TMPSourceEnums.h"

@class TMPSourceRedirectInfo;

/**
 Source object in TakeMe Pay system, it represents an instance of a source.
 */
@interface TMPSource : NSObject <TMDictionaryConvertible>

/**
 Source Identifier, unique.
 */
@property (nonatomic, strong, readonly) NSString *sourceId;

/**
 The amount associated with the source.
 */
@property (nonatomic, strong, readonly) NSNumber *amount;

/**
 The client secret of the source, used for TakeMe Pay SDK ( client side ) fetching of a source using a public key, which means if you want to retrieve source by using public key, you must use client secret value, the client secret value is getting when you create it.
 */
@property (nonatomic, strong, readonly) NSString *clientSecret;

/**
 When the source was created.
 */
@property (nonatomic, strong, readonly) NSDate *created;

/**
 When the source was updated.
 */
@property (nonatomic, strong, readonly) NSDate *updated;

/**
 The currency associated with the source.
 */
@property (nonatomic, strong, readonly) NSString *currency;

/**
 A set of key/value pairs associated with the source, for extensible abilities in the future.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *metadata;

/**
 Description of the source, it will show on the checkout counter in default UI.
 */
@property (nonatomic, strong, readonly) NSString *sourceDescription;

/**
 Indicates whether current environment is sandbox ( for debugging purpose ) environment, it's decided by the type of public key you provided in TMPConstants.h.
 */
@property (nonatomic, assign, readonly) BOOL sandboxEnv;

/**
 The type of the source.
 */
@property (nonatomic, assign, readonly) TMPSourceType type;

/**
 The flow of the source.
 */
@property (nonatomic, assign, readonly) TMPSourceFlow flow;

/**
 The current status of the source.
 */
@property (nonatomic, assign, readonly) TMPSourceStatus status;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("Can't be created directly, received from delegate of TMPPayment or TMPSourceContext")));

@end

@interface TMPSource (TMPPayment)

/**
 The payload is used for payment, it contains necessary information about specific payment
 */
@property (nonatomic, strong) NSDictionary *payload;

@end

@interface TMPSource (TMPRedirect)

/**
 Information related to the redirect flow, if flow of the source is not TMPSourceFlowRedirect, it will be nil.
 */
@property (nonatomic, strong) TMPSourceRedirectInfo *redirect;

@end

@interface TMPSourceRedirectInfo : NSObject

/**
 Represents redirect destination url, it could be an app scheme or web site url.
 */
@property (nonatomic, strong) NSURL *redirectUrl;

/**
 Represents the return destination url, it used by TakeMe Pay SDK.
 */
@property (nonatomic, strong) NSURL *returnUrl;

/**
 Current status of redirection.
 */
@property (nonatomic, assign) TMPSourceRedirectStatus redirectStatus;

/**
 Reserved, extra information of redirection.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

@end
