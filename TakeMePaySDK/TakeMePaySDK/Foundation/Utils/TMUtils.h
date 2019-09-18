//
//  TMUtils.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMUtils : NSObject

// check if a string is nil or empty
+ (BOOL)stringIsEmpty:(NSString *)string;

// run task on main queue
+ (void)executeOnMainQueue:(dispatch_block_t)task sync:(BOOL)sync;

+ (UIColor *)colorWithHex:(NSString *)hex;
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (BOOL)isNilOrNull:(id)obj;

@end
