//
//  AppEntry.h
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppEntry : NSObject
@property(nonatomic, assign) BOOL isLeaf;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSMutableArray *childEntries;

+ (AppEntry *)rootEntry;
- (id)initWithPath: (NSString *) path;
- (BOOL)addToRootEntry: (AppEntry *) rootEntry;

@end
