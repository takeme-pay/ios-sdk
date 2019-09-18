//
//  UIImageView+TMDownLoadImage.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/8.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "UIImageView+TMDownLoadImage.h"
#import "TMImageLoader.h"
#import <objc/runtime.h>

@implementation UIImageView (DownLoadImage)

- (void)tm_setImageUrl:(NSString *)imageUrl {
    [self tm_setImageUrlIdentifier:imageUrl];
    [TMImageLoader downloadImageWithUrl:imageUrl completion:^(NSString *url, UIImage *image) {
        if ([url isEqualToString:self.tm_imageUrlIdentifier]) {
            self.image = image;
        } else {
            self.image = nil;
        }
    }];
}

- (void)tm_setImageUrlIdentifier:(NSString *)url {
    objc_setAssociatedObject(self, @selector(tm_imageUrlIdentifier), url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)tm_imageUrlIdentifier {
    return objc_getAssociatedObject(self, _cmd);
}

@end
