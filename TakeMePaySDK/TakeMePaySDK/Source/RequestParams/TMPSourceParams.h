//
//  TMPSourceParam.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPSourceEnums.h"

@interface TMPSourceParams : NSObject

@property (nonatomic, assign) BOOL sandboxEnv;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, strong) NSString *sourceDescription;
@property (nonatomic, assign) TMPSourceType type;
@property (nonatomic, assign) TMPSourceFlow flow;

/**
 A convenience initializer to create TMPSourceParams, it may take some further settings after you get an TMPSourceParams instance from this method.

 @param description The description of the item.
 @param amount The amount of the item.
 @param currency The currency of the current payment.
 @return Source Params with your settings.
 */
- (instancetype)initWithDescription:(NSString *)description amount:(NSUInteger)amount currency:(NSString *)currency;

@end

@interface TMPSourceParams (TMPSourceAuthorization)

@property (nonatomic, strong) NSString *clientSecret;

@end
