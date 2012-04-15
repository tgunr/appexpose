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
@synthesize originalImage;
@synthesize appDictionary;


+ (AppEntry *)rootEntry {
    return [[self alloc] initRootWithURL:[NSURL fileURLWithPath: @"/"]];
}

- (AppEntry *)initRootWithURL: (NSURL *) url {
	self = [super init];
	if (self) {
		appURL          = [url copy];
		isLeaf          = YES;
        isApp           = NO;
		name            = [[url lastPathComponent] copy];
        originalImage   = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
        iconImage       = originalImage;
        appDictionary   = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         iconImage, KEY_IMAGE,
                         name, KEY_NAME,
                         nil];
   }
    return self;
}

- (AppEntry *)initWithURL: (NSURL *) url {
	self = [super init];
	if (self) {
		appURL          = [url copy];
		isLeaf          = [self isLeaf: url];
        isApp           = NO;
		name            = [[url lastPathComponent] copy];
        originalImage   = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
		if (isLeaf) {
            iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[appURL path]];
      } else {
			if ([[appURL pathExtension] isEqualToString: @"app"]) {
                isApp = YES;
				isLeaf = !isLeaf;
                iconImage = originalImage;
            } else {
                childEntries = [[NSMutableArray alloc] init];
                iconImage = originalImage;
                if ([self isFolder: url]) {
                    [self scanURLForIcons: url forEntry:self];
                    if ([childEntries count]) {
                        iconImage = [[childEntries objectAtIndex:0] iconImage];
                    }
                }
            }
        }
        appDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         iconImage, KEY_IMAGE,
                         name, KEY_NAME,
                         nil];
    }
    return self;
}
    
-(NSArray *)scanURLForIcons:(NSURL *)directoryToScan forEntry: (AppEntry *)appEntry
{
    // Create a local file manager instance
    NSFileManager *fm =[[NSFileManager alloc] init];
    
    // Enumerate the directory (specified elsewhere in your code)
    // Request the two properties the method uses, name and isDirectory
    // Ignore hidden files
    // The errorHandler: parameter is set to nil. Typically you'd want to present a panel
    NSArray *fileKeys = [NSArray arrayWithObjects:NSURLIsRegularFileKey, NSURLIsDirectoryKey, NSURLCustomIconKey, nil];

    NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:directoryToScan
                                                  includingPropertiesForKeys:fileKeys
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:nil];
    
    // An array to store the all the enumerated file names in
    NSMutableArray *theArray=[NSMutableArray array];
    
    // Enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *theURL in dirEnumerator) {
        
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        // Retrieve whether a directory. From NSURLIsDirectoryKey, also
        // cached during the enumeration.
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        // Ignore files under the _extras directory
        if ([[theURL pathExtension] isEqualToString: @"app"]) {
            AppEntry *entry = [[AppEntry alloc] initWithURL:theURL];
            if (! [appEntry addChildEntry:entry])
                PMERR(1, @"Failed to add childEntry at: %@", [theURL path]);
        }
    }
        return theArray;
}

- (BOOL)isLeaf:(NSURL *) url {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    [fm fileExistsAtPath: [url path] isDirectory: &isDir];
    return !isDir;
}

- (BOOL)isFolder:(NSURL *) url {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    return ![ws isFilePackageAtPath: [url path]];
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
