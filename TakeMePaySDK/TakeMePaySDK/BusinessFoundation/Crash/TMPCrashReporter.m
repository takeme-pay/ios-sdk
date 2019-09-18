//
//  TMPCrashReporter.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/3/4.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPCrashReporter.h"
#import "TMPSDKConstants.h"

@implementation TMPCrashReport

- (instancetype)init {
    if (self = [super init]) {
        _timestamp = NSDate.date.timeIntervalSince1970;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _reason = [aDecoder decodeObjectForKey:@"reason"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _callstackInfo = [aDecoder decodeObjectForKey:@"callstackInfo"];
        _timestamp = [[aDecoder decodeObjectForKey:@"timestamp"] timeIntervalSince1970];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_reason forKey:@"reason"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_callstackInfo forKey:@"callstackInfo"];
    [aCoder encodeObject:[NSDate dateWithTimeIntervalSince1970:_timestamp] forKey:@"timestamp"];
}

@end

@implementation TMPCrashReporter

static NSUncaughtExceptionHandler *_previousHandler = NULL;

+ (void)start {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSUncaughtExceptions
            _previousHandler = NSGetUncaughtExceptionHandler();
            NSSetUncaughtExceptionHandler(&TMUncaughtExceptionHandler);
        });
    });
}

+ (nullable TMPCrashReport *)existedCrashReport:(BOOL)autoRemove {
    NSString *path = crashFilePath();
    TMPCrashReport *crashReport = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if ([crashReport isKindOfClass:TMPCrashReport.class] && autoRemove) {
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        }
    }
    
    return crashReport;
}

void TMUncaughtExceptionHandler(NSException *exception) {
    BOOL isTakeMePaySDKException = NO;
    
    for (NSString *callstack in exception.callStackSymbols) {
        if ([callstack containsString:TMP_SDK_LITERAL]) {
            isTakeMePaySDKException = YES;
            break;
        }
    }
    
    if (isTakeMePaySDKException) {
        TMPCrashReport *report = [[TMPCrashReport alloc] init];
        
        report.callstackInfo = exception.callStackSymbols;
        report.reason = exception.reason;
        report.name = exception.name;
        
        NSString *path = crashFilePath();
        if (path) {
            [NSKeyedArchiver archiveRootObject:report toFile:path];
        }
    }
    
    if (_previousHandler != NULL) {
        _previousHandler(exception);
    }
}

static inline NSString *crashFilePath() {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        if (documentDirectory) {
            path = [documentDirectory stringByAppendingPathComponent:@"TMPSDKCrash.dat"];
        }
    });
    
    return path;
}

@end
