//
//  TMLocalizationUtils.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/8.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMLocalizationUtils : NSObject

+ (NSString *)localizedStringForKey:(NSString *)key;
+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END

static inline NSString * _Nonnull TMLocalizedString(NSString * _Nonnull key, ...) {
    va_list args;
    va_start(args, key);
    NSString *result = [TMLocalizationUtils localizedStringForKey:[[NSString alloc] initWithFormat:key arguments:args]];
    va_end(args);
    
    return result;
}
