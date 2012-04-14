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
@property(nonatomic, strong) NSImage *iconImage;


+ (AppEntry *)rootEntry;
- (AppEntry *)initWithURL: (NSURL *) url;
- (BOOL)addToRootEntry: (AppEntry *) rootEntry;

@end
