//
//  NSMutableDictionary+TMFExtension.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/12/19.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "NSMutableDictionary+TMFExtension.h"

@implementation NSMutableDictionary (TMFExtension)

- (void)tmf_safeSetObject:(id)anObject forKey:(id)aKey {
    if (!anObject || !aKey) {
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}

@end
