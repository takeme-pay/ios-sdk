//
//  NSMutableDictionary+TMFExtension.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/12/19.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary<KeyType, ObjectType> (TMFExtension)

- (void)tmf_safeSetObject:(ObjectType)anObject forKey:(KeyType)aKey;

@end
