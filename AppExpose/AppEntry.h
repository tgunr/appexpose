//
//  AppEntry.h
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XATTR;

#define KEY_IMAGE    @"icon"
#define KEY_NAME    @"name"

@interface AppEntry : NSObject {
	BOOL isLeaf;
	BOOL isApp;
	BOOL isFolder;

	NSString            *name;
	NSURL               *appURL;
	NSMutableArray      *childEntries;
	NSMutableArray      *childIcons;
	NSImage             *iconImage;
	NSImage             *originalImage;
	NSMutableDictionary *appDictionary;
	NSDictionary        *attributes;
	XATTR               *xattr;
}

@property(nonatomic, assign) BOOL isLeaf;
@property(nonatomic, assign) BOOL isApp;
@property(nonatomic, copy) NSString              *name;
@property(nonatomic, copy) NSURL                 *appURL;
@property(nonatomic, strong) NSMutableArray      *childEntries;
@property(nonatomic, strong) NSMutableDictionary *appDictionary;
@property(nonatomic, strong) NSImage             *iconImage;
@property(nonatomic, strong) NSImage             *originalImage;
@property(nonatomic, assign) BOOL isFolder;
@property(nonatomic, strong) NSDictionary *attributes;
@property(nonatomic, strong) XATTR *xattr;


+ (AppEntry *)rootEntry;

- (AppEntry *)initWithURL: (NSURL *) url;

- (AppEntry *)initRootWithURL: (NSURL *) url;

- (BOOL)isALeaf: (NSURL *) url;

- (BOOL)isAFolder: (NSURL *) url;

- (NSArray *)scanURLForIcons: (NSURL *) directoryToScan forEntry: (AppEntry *) appEntry;

- (NSString *)pathWithName;

- (NSComparisonResult)compare: (AppEntry *) other;

- (BOOL)addChildEntry: (AppEntry *) entry;

- (AppEntry *)childDirectoryEntryWithName: (NSString *) str createIfNotPresent: (BOOL) flag;

- (BOOL)addToRootEntry: (AppEntry *) rootEntry;

- (BOOL)setAttribute: (NSString *)xAttribute value: (NSString *)xValue;

- (BOOL)hasAttribute: (NSString *) string;

- (BOOL)deleteAttribute: (NSString *) string;

- (void)revertIcon;

@end
