//
//  TMDictionaryConvertible.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TMDictionaryConvertible <NSObject>

@required
+ (instancetype)convertFromDictionary:(NSDictionary *)dict;
+ (NSDictionary *)convertToDictionary:(id)obj;

@end

NS_ASSUME_NONNULL_END
