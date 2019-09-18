//
//  TMNetworkingOperationManager.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TMNetworkingOperationPurpose) {
    TMNetworkingEndpointRequestPurpose,
    TMNetworkingImageDownloadingPurpose
};

@interface TMNetworkingOperationManager : NSObject

+ (instancetype)sharedManager;

- (void)addOperation:(NSOperation *)operation purpose:(TMNetworkingOperationPurpose)purpose;

@end
