//
//  AppEntry.m
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

#import "AppEntry.h"

@implementation AppEntry {
}
@synthesize isLeaf;
@synthesize isApp;
@synthesize name;
@synthesize appURL;
@synthesize childEntries;
@synthesize iconImage;
@synthesize appDictionary;


+ (AppEntry *)rootEntry {
    return [[self alloc] initWithURL:[NSURL fileURLWithPath: @"/"]];
}

- (AppEntry *)initWithURL: (NSURL *) url {
	self = [super init];
	if (self) {
		appURL      = [url copy];
		isLeaf      = [self isLeaf: url];
        isApp       = NO;
        //		url         = [url initWithString: @"/" relativeToURL: url];
		name        = [[url lastPathComponent] copy];
		if (!isLeaf) {
			if ([[appURL pathExtension] isEqualToString: @"app"]) {
                isApp = YES;
				isLeaf = !isLeaf;
            } else
                childEntries = [[NSMutableArray alloc] init];
            //				NSURL *plistURL = [url URLByAppendingPathComponent:@"Contents/Info.plist"];
            //				NSFileManager *fm = [NSFileManager defaultManager];
            //                NSURL * absoluteFile = [plistURL absoluteURL];
            //				NSString *const aPath = [absoluteFile path];
            //				if ([fm fileExistsAtPath: aPath]) {
            //					NSDictionary *appInfo = [NSDictionary dictionaryWithContentsOfURL:plistURL];
            //					NSString *iconFile = [appInfo objectForKey: @"CFBundleIconFile"];
            //					NSURL *iconURL = [url URLByAppendingPathComponent: [NSString stringWithFormat: @"Resources/%@", iconFile]];
            iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
                appDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 iconImage, KEY_IMAGE,
                                 name, KEY_NAME,
                                 nil];
        }
    }
    return self;
}
    
- (BOOL)isLeaf:(NSURL *) url {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    [fm fileExistsAtPath: [url path] isDirectory: &isDir];
    return !isDir;
}

- (NSString *)pathWithName {
    NSString *path = [[appURL path] stringByAppendingPathComponent:name];
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
        childEntry = [[AppEntry alloc] initWithURL:[NSURL URLWithString: [[[self pathWithName] stringByAppendingPathComponent:str] stringByAppendingString:@"/"]]];
        [self addChildEntry:childEntry];
    }
    return childEntry;
}

- (BOOL)addToRootEntry:(AppEntry *)rootEntry {
	AppEntry *directoryEntry = rootEntry;
    NSArray *components = [appURL pathComponents];
    for (NSString *component in components) {
        if (![@"/" isEqualToString:component]) directoryEntry = [directoryEntry childDirectoryEntryWithName:component createIfNotPresent:YES];
    }
    return directoryEntry ? [directoryEntry addChildEntry:self] : NO;
}

@end
