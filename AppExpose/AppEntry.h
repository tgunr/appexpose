//
//  AppEntry.h
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_IMAGE	@"icon"
#define KEY_NAME	@"name"

@interface AppEntry : NSObject {
    BOOL isLeaf;
    BOOL isApp;
	NSString *name;
	NSURL *appURL;
	NSMutableArray *childEntries;
	NSMutableArray *childIcons;
	NSImage *iconImage;
	NSImage *originalImage;
    NSMutableDictionary *appDictionary;
}

@property(nonatomic, assign) BOOL isLeaf;
@property(nonatomic, assign) BOOL isApp;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSURL *appURL;
@property(nonatomic, strong) NSMutableArray *childEntries;
@property(nonatomic, strong) NSMutableDictionary *appDictionary;
@property(nonatomic, strong) NSImage *iconImage;
@property(nonatomic, strong) NSImage *originalImage;

+ (AppEntry *)rootEntry;
- (AppEntry *)initWithURL: (NSURL *) url;
- (AppEntry *)initRootWithURL: (NSURL *) url;
- (BOOL)isLeaf:(NSURL *) url;
- (BOOL)isFolder:(NSURL *) url;
- (NSArray *)scanURLForIcons:(NSURL *)directoryToScan forEntry: (AppEntry *)appEntry;
- (NSString *)pathWithName;
- (NSComparisonResult)compare:(AppEntry *)other;
- (BOOL)addChildEntry:(AppEntry *)entry;
- (AppEntry *)childDirectoryEntryWithName:(NSString *)str createIfNotPresent:(BOOL)flag;
- (BOOL)addToRootEntry: (AppEntry *) rootEntry;
@end
