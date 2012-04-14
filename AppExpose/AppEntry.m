//
//  AppEntry.m
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import "AppEntry.h"

@implementation AppEntry {
	BOOL isLeaf;
	NSString *name;
	NSString *leadingPath;
	NSMutableArray *childEntries;
}
@synthesize isLeaf;
@synthesize name;
@synthesize childEntries;


+ (AppEntry *)rootEntry {
    return [[self alloc] initWithPath:@"/"];
}

- (id)initWithPath:(NSString *)path {
	self = [super init];
	if (self) {
		isLeaf           = [self isLeaf:path];
		path             = [@"/" stringByAppendingPathComponent: path];
		name             = [[path lastPathComponent] copy];
		leadingPath      = [[path stringByDeletingLastPathComponent] copy];
		if (!isLeaf)                                        {
			childEntries = [[NSMutableArray alloc] init];
		}
	}
	return self;
}

- (BOOL)isLeaf:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    [fm fileExistsAtPath:path isDirectory: &isDir];
    return !isDir;
}

- (NSString *)path {
    NSString *path = [leadingPath stringByAppendingPathComponent:name];
    return isLeaf ? path : [path stringByAppendingString:@"/"];
}

- (NSComparisonResult)compare:(AppEntry *)other {
    return [[self name] localizedCaseInsensitiveCompare:[other name]];
}

- (BOOL)addChildEntry:(AppEntry *)entry {
    if (!childEntries)
	    return NO;
    [childEntries addObject:entry];
    [childEntries sortUsingSelector:@selector(compare:)];
    return YES;
}

- (AppEntry *)childDirectoryEntryWithName:(NSString *)str createIfNotPresent:(BOOL)flag {
	AppEntry *childEntry = nil;
    for (AppEntry *entry in childEntries) {
        if ([[entry name] isEqualToString:str] && ![entry isLeaf]) {
            childEntry = (AppEntry *)entry;
            break;
        }
    }
    if (!childEntry && flag && !isLeaf) {
        childEntry = [[AppEntry alloc] initWithPath:[[[self path] stringByAppendingPathComponent:str] stringByAppendingString:@"/"]];
        [self addChildEntry:childEntry];
    }
    return childEntry;
}

- (BOOL)addToRootEntry:(AppEntry *)rootEntry {
	AppEntry *directoryEntry = rootEntry;
    NSArray *components = [leadingPath pathComponents];
    for (NSString *component in components) {
        if (![@"/" isEqualToString:component]) directoryEntry = [directoryEntry childDirectoryEntryWithName:component createIfNotPresent:YES];
    }
    return directoryEntry ? [directoryEntry addChildEntry:self] : NO;
}

@end
