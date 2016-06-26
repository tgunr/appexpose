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
#define ICON_SIZE 1024.0
#define DEFAULT_ICON_SIZE 128.0
#define CUSTOM_ICON_NAME @"Icon\r"
#define CUSTOM_ICON_ID @"com.polymicrosystems.appexpose.customicon"
#define MAX_LEVEL 2

@interface AppEntry : NSObject {
	BOOL isLeaf;
	BOOL isApp;
	BOOL isFolder;
    BOOL canAccess;
    BOOL hasCustomIcon;

	NSString            *name;
	NSURL               *appURL;
	NSMutableArray      *childEntries;
	NSMutableArray      *childIcons;
	NSImage             *iconImage;
	NSImage             *originalImage;
	NSMutableDictionary *iconDictionary;
	NSDictionary        *attributes;
	XATTR               *xattr;
}

@property(nonatomic, assign) BOOL isLeaf;
@property(nonatomic, assign) BOOL isApp;
@property(nonatomic, assign) BOOL canAccess;
@property(nonatomic, assign) BOOL hasCustomIcon;
@property(nonatomic, assign, getter = hasMyCustomIcon) BOOL hasMyCustomIcon;
@property(nonatomic, assign, getter = shouldSkipDescendents) BOOL skipDescendents;
@property(nonatomic, copy) NSString              *name;
@property(nonatomic, copy) NSURL                 *appURL;
@property(nonatomic, strong) NSMutableArray      *childEntries;
@property(nonatomic, strong) NSMutableDictionary *iconDictionary;
@property(nonatomic, strong) NSImage             *iconImage;
@property(nonatomic, strong) NSImage             *originalImage;
@property(nonatomic, assign) BOOL isFolder;
@property(nonatomic, strong) NSDictionary *attributes;
@property(nonatomic, strong) XATTR *xattr;

+ (AppEntry *)rootEntry;

- (AppEntry *)initWithURL: (NSURL *) url NS_DESIGNATED_INITIALIZER;

- (AppEntry *)initRootWithURL: (NSURL *) url NS_DESIGNATED_INITIALIZER;

- (BOOL)isALeaf: (NSURL *) url;

- (BOOL)isAFolder: (NSURL *) url;

- (BOOL) isAnApp:(NSURL *) url;

- (void)scanURLForIcons: (NSURL *) directoryToScan forEntry: (AppEntry *) appEntry;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *pathWithName;

- (NSComparisonResult)compare: (AppEntry *) other;

- (BOOL)addChildEntry: (AppEntry *) entry;

- (AppEntry *)childDirectoryEntryWithName: (NSString *) str createIfNotPresent: (BOOL) flag;

- (BOOL)addToRootEntry: (AppEntry *) rootEntry;

- (BOOL)setAttribute: (NSString *)xAttribute value: (NSString *)xValue;

- (BOOL)hasAttribute: (NSString *) string;

- (BOOL)deleteAttribute: (NSString *) string;

- (void)revertIcon;

- (void) badgeAsNoAccess;

- (void) badgeAsFolder;

@end
