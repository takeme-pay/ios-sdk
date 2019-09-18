//
//  TMUtils.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TMUtils.h"

@implementation TMUtils

+ (BOOL)stringIsEmpty:(NSString *)string {
    return ![string isKindOfClass:NSString.class] || string.length == 0;
}

+ (void)executeOnMainQueue:(dispatch_block_t)task sync:(BOOL)sync {
    if (!NSThread.isMainThread) {
        if (!sync) {
            dispatch_async(dispatch_get_main_queue(), task);
        } else {
            dispatch_sync(dispatch_get_main_queue(), task);
        }
    } else {
        task();
    }
}

+ (UIColor *)colorWithHex:(NSString *)hexString {
    if (![hexString hasPrefix:@"#"]) {
        return UIColor.clearColor;
    }
    
    unsigned int hex = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    scanner.scanLocation = 1;
    [scanner scanHexInt:&hex];
    
    CGFloat red   = ((hex & 0xFF0000) >> 16) / 255.0f;
    CGFloat green = ((hex & 0x00FF00) >>  8) / 255.0f;
    CGFloat blue  =  (hex & 0x0000FF) / 255.0f;
    
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)isNilOrNull:(id)obj {
    return
    obj == nil ||
    [obj isKindOfClass:NSNull.class];
}

@end
