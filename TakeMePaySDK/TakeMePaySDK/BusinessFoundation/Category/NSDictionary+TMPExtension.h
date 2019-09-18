//
//  NSDictionary+TMPExtension.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/22.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (TMPExtension)

+ (instancetype)tmp_dictionaryFromPlistWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
