//
//  TMLocalizationUtils.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/8.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMLocalizationUtils.h"

@implementation TMLocalizationUtils

+ (NSString *)localizedStringForKey:(NSString *)key {
    return [self localizedStringForKey:key value:@""];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value {
    if (![NSBundle bundleForClass:self]) {
        return key;
    }
    
    return [[NSBundle bundleForClass:self] localizedStringForKey:key value:value table:nil];
}

@end
