//
//  NSArray+TMFExtension.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TMFExtension)

- (nonnull instancetype)tmf_map:(_Nonnull id(^ __nonnull)(_Nonnull id))transformer;
- (nonnull instancetype)tmf_flatMap:(_Nonnull id(^ __nonnull)(_Nonnull id))transformer;
- (nonnull instancetype)tmf_filter:(BOOL(^ __nonnull)(_Nonnull id))filter;

@end
