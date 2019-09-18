//
//  TMLoggerEnums.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#ifndef TMLoggerEnums_h
#define TMLoggerEnums_h

typedef NS_OPTIONS(NSInteger, TMLogLevel) {
    TMLogLevelDebug = 1,
    TMLogLevelInfo = 1 << 1,
    TMLogLevelWarn = 1 << 2,
    TMLogLevelError = 1 << 3,
    TMLogLevelFatal = 1 << 4,   // fatal == crash, do not abuse it
    
    TMLogLevelAll = TMLogLevelDebug | TMLogLevelInfo | TMLogLevelWarn | TMLogLevelError | TMLogLevelFatal
};

#endif /* TMLoggerEnums_h */
