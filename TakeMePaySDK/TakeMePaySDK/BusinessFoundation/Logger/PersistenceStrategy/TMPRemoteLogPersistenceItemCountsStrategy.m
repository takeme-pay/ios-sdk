//
//  TMPRemoteLogPersistenceItemCountsStrategy.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/3/1.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPRemoteLogPersistenceItemCountsStrategy.h"
#import "TMPRemoteLogReporter.h"
#import "TMUtils.h"
#import "TMLogService.h"
#import "TMLogInformation+TMPErrorConvertible.h"
#import "TMPRemoteLogInfo+TMPPrivate.h"
#import <UIKit/UIKit.h>
#import "NSArray+TMFExtension.h"

static NSString *const PERSISTENCE_FILE_PREFIX = @"TMP_PENDING_ERROR_LOG_FILE";
static const NSUInteger DEFAULT_PENDING_IN_MEMORY_MAX_COUNT = 5;
static const NSUInteger DEFAULT_PERSITENCE_IN_DISK_MAX_COUNT = 3;

@implementation TMPRemoteLogPersistenceItemCountsStrategyBuilder @end

@interface TMPRemoteLogPersistenceItemCountsStrategy ()

@property (nonatomic, assign) dispatch_queue_t workQueue;
@property (nonatomic, strong) NSMutableArray<TMPRemoteLogInfo *> *pendingRemoteLogInfos;

// configuration properties
@property (nonatomic, assign) NSUInteger persistenceMaxCount;
@property (nonatomic, assign) NSUInteger pendingMaxCount;

@end

@implementation TMPRemoteLogPersistenceItemCountsStrategy

@synthesize delegate = _delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithBuilder:(void(^)(TMPRemoteLogPersistenceItemCountsStrategyBuilder * _Nonnull))block {
    if (self = [super init]) {
        TMPRemoteLogPersistenceItemCountsStrategyBuilder *builder = [[TMPRemoteLogPersistenceItemCountsStrategyBuilder alloc] init];
        
        if (block) {
            block(builder);
            
            _delegate = builder.delegate;
            _persistenceMaxCount = builder.persistenceMaxCount == 0 ? DEFAULT_PERSITENCE_IN_DISK_MAX_COUNT : builder.persistenceMaxCount;
            _pendingMaxCount = builder.pendingMaxCount == 0 ? DEFAULT_PENDING_IN_MEMORY_MAX_COUNT : builder.pendingMaxCount;
        }
        
        _pendingRemoteLogInfos = [[NSMutableArray alloc] init];
        
        [self registerNotifications];
        
        // when init, execute once pre-start check and invoke once `isTouchWaterMark` with YES if needed
        [self executePreStartActivities];
    }
    
    return self;
}

#pragma mark - TMPRemoteLogPersistenceStrategy

- (void)receivedData:(nonnull TMPRemoteLogInfo *)data {
    TMPExecuteTaskOnWorkQueue(^{
        if (![data isKindOfClass:TMPRemoteLogInfo.class]) {
            return;
        }
        
        [self addPendingData:data];
    }, NO);
}

- (NSArray<TMPRemoteLogInfo *> *)persistedData {
    __block NSArray<TMPRemoteLogInfo *> *result = @[];
    
    TMPExecuteTaskOnWorkQueue(^{
        result = convertPersistedFileDirsToDictionary(searchAllPersistedFiles());
    }, YES);
    
    return result;
}

- (BOOL)purgeData:(nonnull NSArray<TMPRemoteLogInfo *> *)toBePurgedData {
    NSMutableSet<NSNumber *> *purgeResults = [[NSMutableSet alloc] init];
    
    TMPExecuteTaskOnWorkQueue(^{
        NSMutableSet<NSString *> *possibleFilePaths = [[NSMutableSet alloc] init];
        
        [toBePurgedData enumerateObjectsUsingBlock:^(TMPRemoteLogInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:TMPRemoteLogInfo.class] && ![TMUtils stringIsEmpty:obj.tmp_associatedFileName]) {
                [possibleFilePaths addObject:obj.tmp_associatedFileName];
            }
        }];
        
        if (possibleFilePaths.count != 0) {
            [possibleFilePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:NSString.class]) {
                    BOOL removeResult = [self removeFileSync:obj];
                    [purgeResults addObject:@(removeResult)];
                }
            }];
        }
    }, YES);
    
    return purgeResults.count == 1 && [purgeResults.anyObject isEqualToNumber:@(YES)];
}

#pragma mark - private

- (void)registerNotifications {
    // when enter background or terminate, force save pending log infos into file
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterBackgroundOrTerminate:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterBackgroundOrTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    // when enter foreground, force invoke once `persistItemFinished:isTouchWaterMark:` with YES, to send to remote server
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)addPendingData:(TMPRemoteLogInfo *)data {
    NSAssert(TMPIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    if ([data isKindOfClass:TMPRemoteLogInfo.class]) {
        [self.pendingRemoteLogInfos addObject:data];
        
        [self synclySaveToFileIfNeeded];
    }
}

- (void)synclySaveToFileIfNeeded {
    NSAssert(TMPIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    NSArray<TMPRemoteLogInfo *> *scopedArray = [[NSArray alloc] initWithArray:self.pendingRemoteLogInfos];
    
    if (scopedArray.count > self.pendingMaxCount) {
        static const NSInteger SAVE_FILE_RETRY_TIME = 3;
        
        BOOL saveSuccessfully = NO;
        for (NSInteger i = 0; i < SAVE_FILE_RETRY_TIME; i++) {
            if ([self writeToFileSync:self.distributeAnAvailableFilePath data:scopedArray]) {
                if ([self.delegate respondsToSelector:@selector(persistItemFinished:isTouchWaterMark:)]) {
                    [self.delegate persistItemFinished:self isTouchWaterMark:self.checkIfReachwaterMark];
                }
                
                saveSuccessfully = YES;
                [self.pendingRemoteLogInfos removeObjectsInArray:scopedArray];
                
                break;
            }
        }
        
        if (!saveSuccessfully && [self.delegate respondsToSelector:@selector(sendDirectlyIfInEmergencyCase:completion:)]) {
            [self.delegate sendDirectlyIfInEmergencyCase:scopedArray completion:^(BOOL success) {
                TMPExecuteTaskOnWorkQueue(^{
                    if (success) {
                        // purge inside the strategy class, because I don't want caller to care about how to handle with failure case of `writeToFile:data:`
                        // other cases, we should always delegate the result to delegate
                        [self purgeData:scopedArray];
                        
                        [self.pendingRemoteLogInfos removeObjectsInArray:scopedArray];
                    }
                    
                    // if success == false
                    // if failed, do not execute purging, just keep them in the pending data, then invoke next time `synclySaveToFileIfNeeded` to try to save them into files, noted, this file is larger than normal one
                }, NO);
            }];
        }
    }
}

- (BOOL)writeToFileSync:(NSString *)path data:(NSArray<id<NSCoding>> *)pendings {
    NSAssert(TMPIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    if ([TMUtils stringIsEmpty:path] || ![pendings isKindOfClass:NSArray.class]) {
        return NO;
    }
    
    // for purging purpose
    for (TMPRemoteLogInfo *logInfo in pendings) {
        if ([logInfo isKindOfClass:TMPRemoteLogInfo.class]) {
            logInfo.tmp_associatedFileName = path;
        }
    }
    
    BOOL result = [NSKeyedArchiver archiveRootObject:pendings toFile:path];
    
    if (!result) {
        for (TMPRemoteLogInfo *logInfo in pendings) {
            if ([logInfo isKindOfClass:TMPRemoteLogInfo.class]) {
                logInfo.tmp_associatedFileName = nil;
            }
        }
    }
    
    return result;
}

- (BOOL)removeFileSync:(NSString *)path {
    NSAssert(TMPIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    if ([TMUtils stringIsEmpty:path]) {
        return NO;
    }
    
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        NSError *error;
        [NSFileManager.defaultManager removeItemAtPath:path error:&error];
        
        return error == nil;
    }
    
    return NO;
}

- (NSString *)distributeAnAvailableFilePath {
    NSAssert(TMPIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    static NSUInteger uniqueID = 0;
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    BOOL pathIsAvailable = NO;
    NSString *result = nil;
    
    // use case for restart app, unique id start from 0 again, but there was a file already existed.
    do {
        NSString *fileName = [NSString stringWithFormat:@"/%@%lu.dat", PERSISTENCE_FILE_PREFIX, (unsigned long)uniqueID++];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheDir stringByAppendingString:fileName]]) {
            pathIsAvailable = YES;
            
            result = [cacheDir stringByAppendingString:fileName];
        }
    } while (!pathIsAvailable);
    
    return result;
}

- (BOOL)checkIfReachwaterMark {
    NSAssert(TMPIsRemoteLogPersistWorkQueue(), @"should run on work queue");
    
    return self.persistedData.count > self.persistenceMaxCount;
}

- (void)executePreStartActivities {
    TMPExecuteTaskOnWorkQueue(^{
        if (self.persistedData.count > 0 && [self.delegate respondsToSelector:@selector(persistItemFinished:isTouchWaterMark:)]) {
            // here, use YES for `isTouchWaterMark` field forcely, to invoke an upload to remote server
            [self.delegate persistItemFinished:self isTouchWaterMark:YES];
        }
    }, NO);
}

#pragma mark - notification responder

- (void)applicationWillEnterBackgroundOrTerminate:(NSNotification *)notification {
    TMPExecuteTaskOnWorkQueue(^{
        if (self.pendingRemoteLogInfos.count > 0) {
            if ([self writeToFileSync:self.distributeAnAvailableFilePath data:self.pendingRemoteLogInfos]) {
                [self.pendingRemoteLogInfos removeAllObjects];
            }
        }
    }, NO);
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // is same as `executePreStartActivities`, check if crash report existed, and check if exist persistedData, then forcely invoke `isTouchWaterMark` with YES
    [self executePreStartActivities];
}

#pragma mark - getter

static dispatch_queue_t TMPGetRemoteLogPersistWorkQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.takemepay.logger.persist.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

#pragma mark - utils

static BOOL TMPIsRemoteLogPersistWorkQueue() {
    static void *queueKey = &queueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(TMPGetRemoteLogPersistWorkQueue(), queueKey, queueKey, NULL);
    });
    
    return dispatch_get_specific(queueKey) == queueKey;
}

static void TMPExecuteTaskOnWorkQueue(dispatch_block_t task, BOOL sync) {
    if (TMPIsRemoteLogPersistWorkQueue()) {
        if (sync) {
            task();
        } else {
            dispatch_async(TMPGetRemoteLogPersistWorkQueue(), task);
        }
    } else if (sync) {
        dispatch_sync(TMPGetRemoteLogPersistWorkQueue(), task);
    } else {
        dispatch_async(TMPGetRemoteLogPersistWorkQueue(), task);
    }
}

static NSArray<NSString *> *searchAllPersistedFiles() {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in allFilesAtPath(directory)) {
        if ([fileName containsString:PERSISTENCE_FILE_PREFIX]) {
            [result addObject:fileName];
        }
    }
    
    return result.copy;
}

static NSArray<NSString *> *allFilesAtPath(NSString *path) {
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:path error:nil]) {
        BOOL flag = YES;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObjectsFromArray:allFilesAtPath(fullPath)];
            }
        }
    }
    
    return pathArray.copy;
}

static NSArray<TMPRemoteLogInfo *> *convertPersistedFileDirsToDictionary(NSArray<NSString *> *dirs) {
    NSMutableArray<NSArray<TMPRemoteLogInfo *> *> *result = [[NSMutableArray alloc] init];
    
    for (NSString *fullPath in dirs) {
        NSArray<TMPRemoteLogInfo *> *logInfos = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        if (logInfos) {
            [result addObject:logInfos];
        }
    }
    
    return [result tmf_flatMap:^id _Nonnull(id _Nonnull obj) {
        return obj;
    }].copy;
}

@end
