//
//  NSArray+TMFExtension.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "NSArray+TMFExtension.h"

@implementation NSArray (TMFExtension)

- (instancetype)tmf_map:(_Nonnull id(^)(_Nonnull id))transformer {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        [mutableArray addObject:transformer(object)];
    }
    return mutableArray.copy;
}

- (instancetype)tmf_flatMap:(_Nonnull id(^)(_Nonnull id))transformer {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSArray.class]) {
            NSArray *_array = [obj tmf_flatMap:transformer];
            [mutableArray addObjectsFromArray:_array];
            return;
        }
        
        id _obj = transformer(obj);
        
        if (_obj) {
            [mutableArray addObject:_obj];
        }
    }];
    return mutableArray.copy;
}

- (instancetype)tmf_filter:(BOOL (^)(id _Nonnull))filter {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id object in self) {
        if (filter(object)) {
            [mutableArray addObject:object];
        }
    }
    return mutableArray.copy;
}

@end
