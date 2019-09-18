//
//  TMPSourceParams+TMPPrivate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/9.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPSourceParams (TMPPrivate)

@property (nonatomic, strong) NSString *redirectReturnUrl;

@property (nonatomic, readonly) NSString *_rawType;
@property (nonatomic, readonly) NSString *_rawFlow;

+ (TMPSourceType)typeFromRaw:(NSString *)type;
+ (TMPSourceFlow)flowFromRaw:(NSString *)flow;

@end

NS_ASSUME_NONNULL_END
