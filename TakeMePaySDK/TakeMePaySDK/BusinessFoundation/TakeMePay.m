//
//  TakeMePay.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/25.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TakeMePay.h"
#import "TakeMePay+TMPPrivate.h"
#import "TMLogService.h"
#import "TMLogConsolePrinter.h"
#import "TMPRemoteLogReporter.h"
#import "TMLocalizationUtils.h"
#import "TMPSDKConstants.h"
#import "TMPCrashReporter.h"

@implementation TakeMePay

+ (void)initialize {
    // delay to next recycle, because TMPRemoteLogReporter or other component may needs TakeMePay object's variables
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // setup logger
        {
            TMLogService *service = TMLogService.shared;
            
            if ([NSProcessInfo.processInfo.environment isKindOfClass:NSDictionary.class] && NSProcessInfo.processInfo.environment[@"TMP_PRINT_CONSOLE_LOG"]) {
                [service registerObserver:[[TMLogConsolePrinter alloc] init] onLevel:TMLogLevelInfo | TMLogLevelDebug | TMLogLevelError | TMLogLevelWarn];
            }
            
            [service registerObserver:[[TMPRemoteLogReporter alloc] init] onLevel:TMLogLevelError | TMLogLevelFatal];
            
            [service setUpDone];
        }
        
        // setup crash report collection, check if crash report exists
        {
            [TMPCrashReporter start];
            
            TMPCrashReport *crashReport = [TMPCrashReporter existedCrashReport:YES];
            if ([crashReport isKindOfClass:TMPCrashReport.class]) {
                [TMLogService.shared receivedInformation:({
                    TMLogInformation *info = [[TMLogInformation alloc] init];
                    
                    info.logLevel = TMLogLevelFatal;
                    info.message = crashReport.reason;
                    info.extraInfo = @{
                                       @"callstack" : [NSString stringWithFormat:@"%@", crashReport.callstackInfo],
                                       @"name" : crashReport.name ?: @"unknown name",
                                       @"timestamp_in_crash_report" : [NSString stringWithFormat:@"%f", crashReport.timestamp]
                                       };
                    
                    info;
                })];
            }
        }
    });
}

static NSString *_publicKey;
+ (NSString *)publicKey {
    return _publicKey;
}

+ (void)setPublicKey:(NSString *)publicKey {
    _publicKey = publicKey;
}

static NSString *_companyName;
+ (NSString *)companyName {
    return _companyName;
}

+ (void)setCompanyName:(NSString *)companyName {
    _companyName = companyName;
}

static NSString *_distributedUrlSchemeHosts;
+ (NSString *)distributedUrlSchemeHost {
    return _distributedUrlSchemeHosts;
}

+ (void)setDistributedUrlSchemeHost:(NSString *)distributedUrlSchemeHost {
    _distributedUrlSchemeHosts = distributedUrlSchemeHost;
}

static NSString *_wechatPayAppId;
+ (NSString *)wechatPayAppId {
    return _wechatPayAppId;
}

+ (void)setWechatPayAppId:(NSString *)wechatPayAppId {
    _wechatPayAppId = wechatPayAppId;    
}

+ (BOOL)shouldHandleWithUrl:(NSURL *)url {
    __block BOOL result = NO;
    __block id<TMPURLListener> targetListener = nil;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(-self.callbacks.count + 1);
    dispatch_async(self.workQueue, ^{
        for (id<TMPURLListener> listener in self.callbacks) {
            if ([listener respondsToSelector:@selector(shouldHandleWithUrl:)] && [listener shouldHandleWithUrl:url]) {
                targetListener = listener;
                result = YES;
                dispatch_semaphore_signal(sema);
                break;
            } else {
                dispatch_semaphore_signal(sema);
            }
        }
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (targetListener) {
        [self unregisterListener:targetListener];
    }
    
    return result;
}

@end

@implementation TakeMePay (TMPRegisterURLListener)

+ (void)registerListener:(id<TMPURLListener>)listener {
    dispatch_async(self.workQueue, ^{
        if (listener) {
            [self.callbacks addObject:listener];
        }
    });
}

@end
