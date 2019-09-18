//
//  TWImageLoader.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/8.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMImageLoader : NSObject

+ (void)downloadImageWithUrl:(NSString *)url completion:(void(^)(NSString *url, UIImage *image))completion;

@end
