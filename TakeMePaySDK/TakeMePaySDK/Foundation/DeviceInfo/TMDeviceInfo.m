//
//  TMDeviceInfo.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMDeviceInfo.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "TMPReachability.h"

@implementation TMDeviceInfo

+ (NSString *)osVersion {
    static NSString *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = UIDevice.currentDevice.systemVersion;
    });
    return result;
}

+ (NSString *)deviceType {
    static NSString *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname deviceInfo;
        uname(&deviceInfo);
        result = [NSString stringWithCString:deviceInfo.machine encoding:NSUTF8StringEncoding];
    });
    return result;
}

+ (NSString *)networkType {
    TMPReachability *curReach = [TMPReachability reachabilityForInternetConnection];
    
    TMPReachabilityNetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable: {
            return @"not_reachable";
        }
            
        case ReachableViaWWAN: {
            Class telephoneNetWorkClass = (NSClassFromString(@"CTTelephonyNetworkInfo"));
            if (telephoneNetWorkClass != nil) {
                // thread issues
                static CTTelephonyNetworkInfo *telephonyNetworkInfo = nil;
                if (telephonyNetworkInfo == nil) {
                    telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
                }
                
                if ([telephonyNetworkInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
                    return [NSString stringWithFormat:@"%@",telephonyNetworkInfo.currentRadioAccessTechnology];
                }
            }
            
            return @"2g/3g";
        }
            
        case ReachableViaWiFi: {
            return @"wifi";
        }
    }
}

+ (NSString *)carrier {
    static NSString *result = @"";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (NSClassFromString(@"CTTelephonyNetworkInfo")) {
            // thread issues, some versions of TestFlight would occur error
            static CTTelephonyNetworkInfo *telephonyNetworkInfo = nil;
            if (telephonyNetworkInfo == nil) {
                telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
            }
            
            if (NSClassFromString(@"CTCarrier")) {
                CTCarrier *carrier = telephonyNetworkInfo.subscriberCellularProvider;
                
                NSString *mobileCountryCode = [carrier mobileCountryCode];
                NSString *mobileNetworkCode = [carrier mobileNetworkCode];
                
                if ((mobileCountryCode != nil) && (mobileNetworkCode != nil)) {
                    result = [[NSString alloc] initWithFormat:@"%@%@", mobileCountryCode, mobileNetworkCode];
                }
            }
        }
    });
    
    return result;
}

+ (BOOL)isJailbreak {
    static BOOL result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
    });
    return result;
}

@end
